//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use ksni::TrayMethods;
use ksni::menu::*;
use log::{debug, error, info, warn};
use std::fs;
use std::future;
use std::path::{Path, PathBuf};
use std::process::{self, Command};

use crate::check_times::{get_last_check, get_next_check};
use crate::icon_statefile_watcher;
use crate::updates_statefiles::UpdatesStateFiles;

pub struct ArchUpdateTray {
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,
}

// Systray Applet implementation
impl ksni::Tray for ArchUpdateTray {
    // Set id
    fn id(&self) -> String {
        "Arch-Update".into()
    }

    // Set icon
    fn icon_name(&self) -> String {
        match fs::read_to_string(&self.icon_statefile) {
            Ok(icon) => {
                let icon = icon.trim().to_owned();
                debug!("Icon set or updated: {icon}");
                icon
            }
            Err(error) => {
                error!("Unable to set the icon: {error}");
                process::exit(1);
            }
        }
    }

    // Set title
    fn title(&self) -> String {
        "Arch-Update".into()
    }

    // Set tooltip
    fn tool_tip(&self) -> ksni::ToolTip {
        ksni::ToolTip {
            title: "Arch-Update".into(),
            ..Default::default()
        }
    }

    // Run Arch-Update via the desktop file when activated (left click)
    fn activate(&mut self, _x: i32, _y: i32) {
        launch_arch_update(&self.desktop_file);
    }

    // Dynamically rebuild menu when opened (AboutToShow protocol)
    fn menu_about_to_show(&mut self) {}

    // Build menu
    fn menu(&self) -> Vec<ksni::MenuItem<Self>> {
        // Initialize the vector for the menu entries
        let mut menu = Vec::new();

        // Get the number of different update types
        let update_types = [
            &self.updates_statefiles.packages,
            &self.updates_statefiles.aur,
            &self.updates_statefiles.flatpak,
        ]
        .iter()
        .filter(|statefile| count_update_types(statefile))
        .count();

        // Add the "System is up to date" or "X update(s) available" entry, depending on the number
        // of pending updates
        match get_updates_count(&self.updates_statefiles.all) {
            0 => {
                menu.push(
                    StandardItem {
                        label: "System is up to date".into(),
                        enabled: false,
                        ..Default::default()
                    }
                    .into(),
                );
            }

            count => {
                let desktop_file = self.desktop_file.clone();
                let label = if count == 1 {
                    "1 update available".into()
                } else {
                    format!("{count} updates available")
                };

                menu.push(
                    StandardItem {
                        label,
                        activate: Box::new(move |_| {
                            launch_arch_update(&desktop_file);
                        }),
                        ..Default::default()
                    }
                    .into(),
                );
            }
        }

        // Add the "All" entry, if there are updates available in at least 2 different update types
        // (packages, aur, flatpak)
        if update_types >= 2 {
            let count = get_updates_count(&self.updates_statefiles.all);

            menu.push(
                SubMenu {
                    label: format!("All ({count})"),
                    submenu: build_updates_submenu(&self.updates_statefiles.all),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "Packages" entry, if there are packages updates available
        let count = get_updates_count(&self.updates_statefiles.packages);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: format!("Packages ({count})"),
                    submenu: build_updates_submenu(&self.updates_statefiles.packages),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "AUR" entry, if there are AUR updates available
        let count = get_updates_count(&self.updates_statefiles.aur);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: format!("AUR ({count})"),
                    submenu: build_updates_submenu(&self.updates_statefiles.aur),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "Flatpak" entry, if there are flatpak updates available
        let count = get_updates_count(&self.updates_statefiles.flatpak);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: format!("Flatpak ({count})"),
                    submenu: build_updates_submenu(&self.updates_statefiles.flatpak),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add a separator if relevant
        if update_types > 0 {
            menu.push(MenuItem::Separator);
        }

        // Add the "Last Check" menu entry (if the updates check time statefile is not empty)
        // The reason why this entry is conditonal is because the updates check time statefile
        // may be empty until the first check for updates is performed, so we have to handle this
        // case
        if let Some(last_check) = get_last_check(&self.updates_statefiles.time) {
            menu.push(
                StandardItem {
                    label: format!("Last check {last_check} ago"),
                    enabled: false,
                    ..Default::default()
                }
                .into(),
            );
        } else {
            warn!("Unable to determine the last Arch-Update check time");
        }

        // Add the "Next Check" menu entry (if the systemd timer is started / enabled)
        // The reason why this entry is conditonal is because the systemd timer for the automated
        // checks may not be started / enabled
        if let Some(next_check) = get_next_check() {
            menu.push(
                StandardItem {
                    label: format!("Next check in {next_check}"),
                    enabled: false,
                    ..Default::default()
                }
                .into(),
            );
        } else {
            warn!("Unable to determine next Arch-Update check time");
        }

        // Add a menu group containing a separator and the "Run Arch-Update", "Check for updates" & "Exit" buttons
        let desktop_file = self.desktop_file.clone();

        menu.extend([
            MenuItem::Separator,
            StandardItem {
                label: "Run Arch-Update".into(),
                activate: Box::new(move |_| {
                    launch_arch_update(&desktop_file);
                }),
                ..Default::default()
            }
            .into(),
            StandardItem {
                label: "Check for updates".into(),
                activate: Box::new(
                    |_| match Command::new("arch-update").arg("--check").spawn() {
                        Ok(_) => info!("Arch-Update check executed"),
                        Err(error) => error!("Unable to execute Arch-Update check: {error}"),
                    },
                ),
                ..Default::default()
            }
            .into(),
            StandardItem {
                label: "Exit".into(),
                activate: Box::new(|_| {
                    info!("Exited on user request");
                    process::exit(0);
                }),
                ..Default::default()
            }
            .into(),
        ]);
        menu
    }
}

// Helper to run Arch-Update from the desktop file (via `gio`)
fn launch_arch_update(desktop_file: &Path) {
    match Command::new("gio").arg("launch").arg(desktop_file).spawn() {
        Ok(_) => info!("Arch-Update launched"),
        Err(error) => error!("Unable to launch Arch-Update: {error}"),
    }
}

// Helper to get the number of pending updates from the updates statefile
fn get_updates_count(updates_statefile: &Path) -> usize {
    fs::read_to_string(updates_statefile)
        .unwrap_or_default()
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count()
}

// Helper to get the number of types (packages, aur, flatpak) having available updates
fn count_update_types(updates_statefile: &Path) -> bool {
    get_updates_count(updates_statefile) > 0
}

// Helper to get the list of pending updates from the updates statefile and populate the submenus
// accordingly
fn build_updates_submenu(updates_statefile: &Path) -> Vec<ksni::MenuItem<ArchUpdateTray>> {
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
) -> Vec<ksni::MenuItem<ArchUpdateTray>> {
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
                label: "Next page".into(),
                submenu: build_updates_submenu_pagination(updates, page + 1),
                ..Default::default()
            }
            .into(),
        );
    }

    menu
}

// Helper to open package url
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

// Starting the Systray Applet
pub async fn run(
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,
    i18n_dir: PathBuf,
) {
    // Clone icon statefile path variable (used by the watcher)
    let watcher_icon_statefile = icon_statefile.clone();

    let tray = ArchUpdateTray {
        icon_statefile,
        updates_statefiles,
        desktop_file,
    };

    // Start the systray applet
    let handle = tray
        .spawn()
        .await
        .expect("Unable to start the systray applet");

    info!("Systray applet started");

    // Rebuild the systray applet on icon statefile content changes
    tokio::spawn(icon_statefile_watcher::watch(
        watcher_icon_statefile,
        handle.clone(),
    ));

    // Run forever
    future::pending().await
}
