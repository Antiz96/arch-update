//! Collection of helpers / functions used by the systray applet for various needs and features

use gettextrs::*;
use ksni::Handle;
use ksni::menu::*;
use log::{error, info};
use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use serde::Deserialize;
use std::fs;
use std::path::Path;
use std::path::PathBuf;
use std::process::Command;
use std::thread::sleep;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::sync::mpsc;

use crate::tray;

// Helper to run Arch-Update from the desktop file (via `gio`)
pub fn launch_arch_update(desktop_file: &Path) {
    match Command::new("gio").arg("launch").arg(desktop_file).spawn() {
        Ok(_) => info!("Arch-Update launched"),
        Err(error) => error!("Unable to launch Arch-Update: {error}"),
    }
}

// Helper to get the number of pending updates from the updates statefile
pub fn get_updates_count(updates_statefile: &Path) -> usize {
    fs::read_to_string(updates_statefile)
        .unwrap_or_default()
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count()
}

// Helper to get the number of types (packages, aur, flatpak) having available updates
pub fn count_update_types(updates_statefile: &Path) -> bool {
    get_updates_count(updates_statefile) > 0
}

// Helper to get the list of pending updates from the updates statefile and populate the submenus
// accordingly
pub fn build_updates_submenu(
    updates_statefile: &Path,
) -> Vec<ksni::MenuItem<tray::ArchUpdateTray>> {
    match fs::read_to_string(updates_statefile) {
        Ok(updates) => {
            let updates: Vec<_> = updates
                .lines()
                .filter(|line| !line.trim().is_empty())
                .collect();

            build_updates_submenu_pagination(&updates, 0)
        }

        Err(error) => {
            error!("Unable to read updates statefile: {error}");
            Vec::new()
        }
    }
}

// Helper to handle pagination for updates submenus
// Set a limit to 20 packages per page, split to another page otherwise
const UPDATES_PER_PAGE: usize = 20;
fn build_updates_submenu_pagination(
    updates: &[&str],
    page: usize,
) -> Vec<ksni::MenuItem<tray::ArchUpdateTray>> {
    let start = page * UPDATES_PER_PAGE;
    let end = (start + UPDATES_PER_PAGE).min(updates.len());

    let mut menu = updates[start..end]
        .iter()
        .map(|update| {
            let package = update
                .split_whitespace()
                .next()
                .unwrap_or_default()
                .to_owned();

            StandardItem {
                label: (*update).into(),
                activate: Box::new(move |_| {
                    open_package_url(&package);
                }),
                ..Default::default()
            }
            .into()
        })
        .collect::<Vec<_>>();

    if end < updates.len() {
        menu.push(
            SubMenu {
                label: gettext("Next page"),
                submenu: build_updates_submenu_pagination(updates, page + 1),
                ..Default::default()
            }
            .into(),
        );
    }

    menu
}

// Helper to open package url when clicking on the package update entry
fn open_package_url(package: &str) {
    let pacman_output = match Command::new("pacman").arg("-Qi").arg(package).output() {
        Ok(pacman_output) => pacman_output,
        Err(error) => {
            error!("Unable to query the {package} package information: {error}");
            return;
        }
    };

    if !pacman_output.status.success() {
        error!("Unable to get the {package} package information");
        return;
    }

    let pacman_stdout = String::from_utf8_lossy(&pacman_output.stdout);

    for line in pacman_stdout.lines() {
        if let Some(url) = line.strip_prefix("URL") {
            let url = url.trim_matches(|column| column == ':' || column == ' ');

            // Make sure to only send URLs to xdg-open
            if url.starts_with("http://") || url.starts_with("https://") {
                match Command::new("xdg-open").arg(url).spawn() {
                    Ok(_) => info!("Opened the {package} package URL: {url}"),
                    Err(error) => error!("Unable to open the {package} package URL {url}: {error}"),
                }
            }

            break;
        }
    }
}

// Watcher for the icon statefile, allowing to trigger a dynamic rebuild of the systray applet on
// icon change
pub async fn icon_watcher(icon_statefile: PathBuf, handle: Handle<crate::tray::ArchUpdateTray>) {
    let (tx, mut rx) = mpsc::unbounded_channel();

    let mut watcher = RecommendedWatcher::new(
        move |result| {
            let _ = tx.send(result);
        },
        Config::default(),
    )
    .expect("Unable to create icon statefile watcher");

    watcher
        .watch(&icon_statefile, RecursiveMode::NonRecursive)
        .expect("Unable to watch icon statefile");

    while let Some(Ok(event)) = rx.recv().await {
        if matches!(event.kind, EventKind::Modify(_)) {
            handle.update(|_| {}).await;
        }
    }
}

// Helper to get the next check time from the systemd timer metadata
#[derive(Deserialize)]
struct SystemdTimer {
    next: Option<u64>,
}

pub fn get_next_check() -> Option<String> {
    let systemctl_output = Command::new("systemctl")
        .args(["--user", "list-timers", "arch-update.timer", "-o", "json"])
        .output()
        .ok()?;

    if !systemctl_output.status.success() {
        return None;
    }

    let timers: Vec<SystemdTimer> = serde_json::from_slice(&systemctl_output.stdout).ok()?;
    let next_run = timers.first()?.next?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?;
    let remaining_time = Duration::from_micros(next_run).checked_sub(now)?;

    format_time(remaining_time)
}

// Helper to get the last check time from the "time" statefile
fn read_last_check(updates_statefile_time: &Path) -> Option<String> {
    let check_time = fs::read_to_string(updates_statefile_time)
        .ok()?
        .lines()
        .next()?
        .parse::<u64>()
        .ok()?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?;
    let past_time = now.checked_sub(Duration::from_secs(check_time))?;

    format_time(past_time)
}

// Wrapper around the "read_last_check" function including a grace period (retry each 200ms up to 2s)
// This is to avoid logging useless and noisy warnings about the check_time statefile not being
// accessible in the short window of time where it gets briefly emptied as it is being re-written
// during a check for updates
pub fn get_last_check(updates_statefile_time: &Path) -> Option<String> {
    for _ in 0..10 {
        if let Some(check_time) = read_last_check(updates_statefile_time) {
            return Some(check_time);
        }

        sleep(Duration::from_millis(200));
    }

    None
}

// Helper to format the last check / next check time in human readable format
fn format_time(time: Duration) -> Option<String> {
    let mut parts = Vec::new();

    let days = time.as_secs() / 86400;
    let hours = (time.as_secs() % 86400) / 3600;
    let minutes = (time.as_secs() % 3600) / 60;
    let seconds = time.as_secs() % 60;

    if days > 0 {
        parts.push(format!("{days}d"));
    }
    if hours > 0 {
        parts.push(format!("{hours}h"));
    }
    if minutes > 0 {
        parts.push(format!("{minutes}m"));
    }
    if seconds > 0 {
        parts.push(format!("{seconds}s"));
    }

    if parts.is_empty() {
        None
    } else {
        Some(parts.join(" "))
    }
}
