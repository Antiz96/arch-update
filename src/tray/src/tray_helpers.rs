//! Collection of helpers / functions used by the systray applet for various needs and features

use anyhow::{Context, anyhow};
use gettextrs::*;
use ksni::Handle;
use ksni::menu::*;
use log::{error, info, trace, warn};
use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use serde::Deserialize;
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::path::PathBuf;
use std::process::Command;
use std::thread::sleep;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::sync::mpsc;

use crate::tray;

// Helper to run Arch-Update in the terminal emulator configured in the desktop environment
// (as `gio`'s own list of known terminal emulators doesn't honor it)
pub fn launch_arch_update(desktop_file: &Path) {
    // Prefer `xdg-terminal-exec` (the freedesktop standard for launching applications in a
    // terminal emulator), which honors the terminal emulator configured in the `xdg-terminals.list`
    // file
    if let Some(xdg_terminal_exec) = find_in_path("xdg-terminal-exec") {
        match Command::new(&xdg_terminal_exec).arg("arch-update").spawn() {
            Ok(_) => {
                info!("Arch-Update launched via xdg-terminal-exec");
                return;
            }
            Err(error) => {
                warn!("Failed to launch Arch-Update via xdg-terminal-exec: {error}");
            }
        }
    }

    // Otherwise, try to launch Arch-Update in the terminal emulator configured in the desktop
    // environment (KDE `kdeglobals` / GNOME `gsettings` / `$TERMINAL` environment variable)
    if let Some(terminal) = detect_terminal() {
        match launch_in_terminal(&terminal) {
            Ok(_) => {
                info!("Arch-Update launched in the {terminal} terminal emulator");
                return;
            }
            Err(error) => {
                warn!("Failed to launch Arch-Update in the {terminal} terminal emulator: {error}");
            }
        }
    }

    // Fallback: launch the desktop file via `gio`, which relies on GLib's own limited list of
    // known terminal emulators
    match Command::new("gio").arg("launch").arg(desktop_file).spawn() {
        Ok(_) => info!("Arch-Update launched"),
        Err(error) => error!("Failed to launch Arch-Update: {error}"),
    }
}

// Helper to find a program in the PATH (or check it directly if it contains a path)
fn find_in_path(program: &str) -> Option<String> {
    if program.contains('/') {
        let path = Path::new(program);

        return path
            .metadata()
            .ok()
            .filter(|metadata| metadata.is_file() && metadata.permissions().mode() & 0o111 != 0)
            .map(|_| program.to_owned());
    }

    env::var_os("PATH")
        .and_then(|path| {
            env::split_paths(&path)
                .map(|dir| dir.join(program))
                .find(|path| {
                    path.metadata()
                        .map(|metadata| {
                            metadata.is_file() && metadata.permissions().mode() & 0o111 != 0
                        })
                        .unwrap_or(false)
                })
        })
        .map(|path| path.to_string_lossy().into_owned())
}

// Helper to detect the terminal emulator configured in the desktop environment
fn detect_terminal() -> Option<String> {
    // Check the `$TERMINAL` environment variable
    if let Some(terminal) = env::var_os("TERMINAL") {
        let terminal = terminal.to_string_lossy().into_owned();
        let terminal_bin = terminal.split_whitespace().next().unwrap_or(&terminal);

        if find_in_path(terminal_bin).is_some() {
            trace!(
                "Terminal emulator detected from the $TERMINAL environment variable: {terminal}"
            );
            return Some(terminal_bin.to_owned());
        }

        trace!(
            "$TERMINAL environment variable set to {terminal}, but the program wasn't found in PATH"
        );
    } else {
        trace!("The $TERMINAL environment variable is not set");
    }

    // Check the terminal emulator configured in KDE (kdeglobals)
    match kde_terminal() {
        Some(terminal) => match find_in_path(&terminal) {
            Some(_) => {
                trace!("Terminal emulator detected from KDE (kdeglobals): {terminal}");
                return Some(terminal);
            }
            None => {
                trace!(
                    "KDE (kdeglobals) configured terminal {terminal}, but the program wasn't found in PATH"
                );
            }
        },
        None => {
            trace!("No terminal emulator configured in KDE (kdeglobals)");
        }
    }

    // Check the terminal emulator configured in GNOME (gsettings)
    match gnome_terminal() {
        Some(terminal) => match find_in_path(&terminal) {
            Some(_) => {
                trace!("Terminal emulator detected from GNOME (gsettings): {terminal}");
                return Some(terminal);
            }
            None => {
                trace!(
                    "GNOME (gsettings) configured terminal {terminal}, but the program wasn't found in PATH"
                );
            }
        },
        None => {
            trace!("No terminal emulator configured in GNOME (gsettings)");
        }
    }

    None
}

// Helper to get the terminal emulator configured in KDE (from the `kdeglobals` configuration file)
fn kde_terminal() -> Option<String> {
    let config_dir = match env::var_os("XDG_CONFIG_HOME") {
        Some(config_home) => PathBuf::from(config_home),
        None => env::var_os("HOME").map(|home| PathBuf::from(home).join(".config"))?,
    };
    let content = fs::read_to_string(config_dir.join("kdeglobals")).ok()?;

    kde_terminal_from(&content)
}

// Helper to parse the terminal emulator configured in KDE from the `kdeglobals` file content
fn kde_terminal_from(content: &str) -> Option<String> {
    let mut terminal_service = None;

    for line in content.lines() {
        let line = line.trim();

        if let Some(application) = line.strip_prefix("TerminalApplication=") {
            if !application.is_empty() {
                return Some(application.to_owned());
            }
        } else if let Some(service) = line.strip_prefix("TerminalService=") {
            terminal_service = Some(service.trim_end_matches(".desktop").to_owned());
        }
    }

    terminal_service
}

// Helper to get the terminal emulator configured in GNOME (via `gsettings`)
fn gnome_terminal() -> Option<String> {
    let output = Command::new("gsettings")
        .args([
            "get",
            "org.gnome.desktop.default-applications.terminal",
            "exec",
        ])
        .output()
        .ok()?;

    if !output.status.success() {
        return None;
    }

    let terminal = String::from_utf8_lossy(&output.stdout);
    let terminal = terminal.trim().trim_matches('\'').trim();

    if terminal.is_empty() {
        None
    } else {
        Some(terminal.to_owned())
    }
}

// Helper to launch Arch-Update in the given terminal emulator
fn launch_in_terminal(terminal: &str) -> std::io::Result<()> {
    let terminal_bin = terminal.split_whitespace().next().unwrap_or(terminal);

    Command::new(terminal_bin)
        .args(terminal_command_args(terminal))
        .spawn()?;

    Ok(())
}

// Helper to build the arguments used to run Arch-Update in the given terminal emulator, using the
// appropriate option to run a command in it depending on the terminal emulator
fn terminal_command_args(terminal: &str) -> Vec<String> {
    let terminal_bin = terminal.split_whitespace().next().unwrap_or(terminal);
    let terminal_name = Path::new(terminal_bin)
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(terminal_bin);

    match terminal_name {
        // These terminal emulators take the command to run directly as arguments
        "kitty" | "foot" => vec!["arch-update".into()],
        "wezterm" | "wezterm-gui" => vec!["start".into(), "arch-update".into()],
        // These terminal emulators require the `--` option before the command to run
        "gnome-terminal" | "ptyxis" => vec!["--".into(), "arch-update".into()],
        // These terminal emulators require the `-x` option before the command to run
        "xfce4-terminal" | "mate-terminal" => vec!["-x".into(), "arch-update".into()],
        // Most terminal emulators use the `-e` option to run a command
        _ => vec!["-e".into(), "arch-update".into()],
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

// Helper to get the list of pending updates from the updates statefile as well as the number of
// updates per pages for pagination
pub fn build_updates_submenu(
    updates_statefile: &Path,
) -> Vec<ksni::MenuItem<tray::ArchUpdateTray>> {
    match fs::read_to_string(updates_statefile) {
        Ok(updates) => {
            let updates: Vec<_> = updates
                .lines()
                .filter(|line| !line.trim().is_empty())
                .collect();

            let updates_per_page = env::var("ARCH_UPDATE_TRAY_UPDATES_PER_PAGE")
                .ok()
                .and_then(|value| value.parse::<usize>().ok())
                .unwrap_or(0);

            build_updates_submenu_pagination(&updates, 0, updates_per_page)
        }

        Err(error) => {
            error!("Failed to read updates statefile: {error}");
            Vec::new()
        }
    }
}

// Helper to populate submenus with the list of pending updates and
// handle pagination if needed (0 = no pagination)
fn build_updates_submenu_pagination(
    updates: &[&str],
    page: usize,
    updates_per_page: usize,
) -> Vec<ksni::MenuItem<tray::ArchUpdateTray>> {
    let (start, end) = if updates_per_page == 0 {
        (0, updates.len())
    } else {
        let start = page * updates_per_page;
        let end = (start + updates_per_page).min(updates.len());
        (start, end)
    };

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

    if updates_per_page > 0 && end < updates.len() {
        menu.push(
            SubMenu {
                label: gettext("Next page"),
                submenu: build_updates_submenu_pagination(updates, page + 1, updates_per_page),
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
            warn!("Failed to query the {package} package information: {error}");
            return;
        }
    };

    if !pacman_output.status.success() {
        warn!("Failed to get the {package} package information");
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
                    Err(error) => warn!("Failed to open the {package} package URL {url}: {error}"),
                }
            }

            break;
        }
    }
}

// Watcher for the icon statefile, allowing to trigger a dynamic rebuild of the systray applet on
// icon change
pub async fn icon_watcher(
    icon_statefile: PathBuf,
    handle: Handle<crate::tray::ArchUpdateTray>,
) -> anyhow::Result<()> {
    let (tx, mut rx) = mpsc::unbounded_channel();

    let mut watcher = RecommendedWatcher::new(
        move |result| {
            let _ = tx.send(result);
        },
        Config::default(),
    )
    .context("Failed to create icon statefile watcher")?;

    watcher
        .watch(&icon_statefile, RecursiveMode::NonRecursive)
        .context("Failed to watch icon statefile")?;

    while let Some(result) = rx.recv().await {
        match result {
            Ok(event) => {
                if matches!(event.kind, EventKind::Modify(_)) {
                    handle.update(|_| {}).await;
                }
            }
            Err(error) => {
                return Err(anyhow!("Icon statefile watcher error: {error}"));
            }
        }
    }

    Ok(())
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
        parts.push(gettext("{days}d").replace("{days}", &days.to_string()));
    }
    if hours > 0 {
        parts.push(gettext("{hours}h").replace("{hours}", &hours.to_string()));
    }
    if minutes > 0 {
        parts.push(gettext("{minutes}m").replace("{minutes}", &minutes.to_string()));
    }
    if seconds > 0 {
        parts.push(gettext("{seconds}s").replace("{seconds}", &seconds.to_string()));
    }

    if parts.is_empty() {
        None
    } else {
        Some(parts.join(" "))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn kde_terminal_parses_terminal_application() {
        let content = "[General]\nTerminalApplication=kitty\nTerminalService=kitty.desktop\n";
        assert_eq!(kde_terminal_from(content).as_deref(), Some("kitty"));
    }

    #[test]
    fn kde_terminal_falls_back_to_terminal_service() {
        let content = "[General]\nTerminalService=org.gnome.Console.desktop\n";
        assert_eq!(
            kde_terminal_from(content).as_deref(),
            Some("org.gnome.Console")
        );
    }

    #[test]
    fn kde_terminal_empty() {
        let content = "[General]\n";
        assert_eq!(kde_terminal_from(content), None);
    }

    #[test]
    fn terminal_command_args_kitty() {
        assert_eq!(
            terminal_command_args("kitty"),
            vec!["arch-update".to_string()]
        );
    }

    #[test]
    fn terminal_command_args_wezterm() {
        assert_eq!(
            terminal_command_args("wezterm"),
            vec!["start".to_string(), "arch-update".to_string()]
        );
    }

    #[test]
    fn terminal_command_args_gnome_terminal() {
        assert_eq!(
            terminal_command_args("gnome-terminal"),
            vec!["--".to_string(), "arch-update".to_string()]
        );
    }

    #[test]
    fn terminal_command_args_default() {
        assert_eq!(
            terminal_command_args("konsole"),
            vec!["-e".to_string(), "arch-update".to_string()]
        );
    }

    #[test]
    fn terminal_command_args_with_path() {
        assert_eq!(
            terminal_command_args("/usr/bin/kitty"),
            vec!["arch-update".to_string()]
        );
    }

    #[test]
    fn launch_arch_update_uses_kde_terminal() {
        let test_dir =
            std::env::temp_dir().join(format!("arch-update-tray-test-{}", std::process::id()));
        let fake_bin = test_dir.join("bin");
        let fake_home = test_dir.join("home");
        let marker = test_dir.join("launched.txt");
        let _ = fs::remove_dir_all(&test_dir);
        fs::create_dir_all(&fake_bin).unwrap();
        fs::create_dir_all(fake_home.join(".config")).unwrap();
        fs::write(
            fake_home.join(".config").join("kdeglobals"),
            "[General]\nTerminalApplication=kitty\n",
        )
        .unwrap();
        fs::write(
            fake_bin.join("kitty"),
            format!(
                "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"{}\"\n",
                marker.display()
            ),
        )
        .unwrap();
        fs::set_permissions(fake_bin.join("kitty"), fs::Permissions::from_mode(0o755)).unwrap();

        let mut path = fake_bin.to_string_lossy().into_owned();
        if let Some(existing) = env::var_os("PATH") {
            path.push(':');
            path.push_str(&existing.to_string_lossy());
        }
        // SAFETY: single-threaded test; no other thread reads these variables concurrently
        unsafe {
            env::set_var("PATH", &path);
            // Simulate the common case where `XDG_CONFIG_HOME` is unset: the `kdeglobals`
            // file must then be looked up in `$HOME/.config`
            env::remove_var("XDG_CONFIG_HOME");
            env::set_var("HOME", &fake_home);
            env::remove_var("TERMINAL");
        }

        launch_arch_update(Path::new("arch-update.desktop"));

        let deadline = std::time::Instant::now() + Duration::from_secs(5);
        let mut launched = String::new();
        while std::time::Instant::now() < deadline {
            if let Ok(content) = fs::read_to_string(&marker) {
                launched = content;
                break;
            }
            sleep(Duration::from_millis(100));
        }

        let _ = fs::remove_dir_all(&test_dir);
        assert_eq!(launched.trim(), "arch-update");
    }
}
