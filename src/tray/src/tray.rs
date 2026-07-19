//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use gettextrs::*;
use ksni::TrayMethods;
use ksni::menu::*;
use log::{debug, error, info, warn};
use std::fs;
use std::future;
use std::path::PathBuf;
use std::process::{self, Command};

use crate::tray_helpers;
use crate::updates_statefiles;

pub struct ArchUpdateTray {
    icon_statefile: PathBuf,
    updates_statefile_type: updates_statefiles::UpdatesStateFiles,
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
        tray_helpers::launch_arch_update(&self.desktop_file);
    }

    // Dynamically rebuild menu when opened (AboutToShow protocol)
    fn menu_about_to_show(&mut self) {}

    // Build menu
    fn menu(&self) -> Vec<ksni::MenuItem<Self>> {
        // Initialize the vector for the menu entries
        let mut menu = Vec::new();

        // Get the number of different update types
        let update_types = [
            &self.updates_statefile_type.packages,
            &self.updates_statefile_type.aur,
            &self.updates_statefile_type.flatpak,
        ]
        .iter()
        .filter(|statefile| tray_helpers::count_update_types(statefile))
        .count();

        // Add the "System is up to date" or "X update(s) available" entry, depending on the number
        // of pending updates
        match tray_helpers::get_updates_count(&self.updates_statefile_type.all) {
            0 => {
                menu.push(
                    StandardItem {
                        label: gettext("System is up to date"),
                        enabled: false,
                        ..Default::default()
                    }
                    .into(),
                );
            }

            count => {
                let desktop_file = self.desktop_file.clone();
                let label = if count == 1 {
                    gettext("1 update available")
                } else {
                    gettext("{count} updates available").replace("{count}", &count.to_string())
                };

                menu.push(
                    StandardItem {
                        label,
                        activate: Box::new(move |_| {
                            tray_helpers::launch_arch_update(&desktop_file);
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
            let count = tray_helpers::get_updates_count(&self.updates_statefile_type.all);

            menu.push(
                SubMenu {
                    label: gettext("All ({count})").replace("{count}", &count.to_string()),
                    submenu: tray_helpers::build_updates_submenu(&self.updates_statefile_type.all),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "Packages" entry, if there are packages updates available
        let count = tray_helpers::get_updates_count(&self.updates_statefile_type.packages);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: gettext("Packages ({count})").replace("{count}", &count.to_string()),
                    submenu: tray_helpers::build_updates_submenu(
                        &self.updates_statefile_type.packages,
                    ),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "AUR" entry, if there are AUR updates available
        let count = tray_helpers::get_updates_count(&self.updates_statefile_type.aur);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: gettext("AUR ({count})").replace("{count}", &count.to_string()),
                    submenu: tray_helpers::build_updates_submenu(&self.updates_statefile_type.aur),
                    ..Default::default()
                }
                .into(),
            );
        }

        // Add the "Flatpak" entry, if there are flatpak updates available
        let count = tray_helpers::get_updates_count(&self.updates_statefile_type.flatpak);

        if count > 0 {
            menu.push(
                SubMenu {
                    label: gettext("Flatpak ({count})").replace("{count}", &count.to_string()),
                    submenu: tray_helpers::build_updates_submenu(
                        &self.updates_statefile_type.flatpak,
                    ),
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
        // The reason why this entry is conditional is because the updates check time statefile
        // may be empty until the first check for updates is performed, so we have to handle this
        // case
        if let Some(last_check) = tray_helpers::get_last_check(&self.updates_statefile_type.time) {
            menu.push(
                StandardItem {
                    label: gettext("Last check {last_check} ago")
                        .replace("{last_check}", &last_check.to_string()),
                    enabled: false,
                    ..Default::default()
                }
                .into(),
            );
        } else {
            warn!("Unable to determine the last Arch-Update check time");
        }

        // Add the "Next Check" menu entry (if the systemd timer is started / enabled)
        // The reason why this entry is conditional is because the systemd timer for the automated
        // checks may not be started / enabled
        if let Some(next_check) = tray_helpers::get_next_check() {
            menu.push(
                StandardItem {
                    label: gettext("Next check in {next_check}")
                        .replace("{next_check}", &next_check.to_string()),
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
                label: gettext("Run Arch-Update"),
                activate: Box::new(move |_| {
                    tray_helpers::launch_arch_update(&desktop_file);
                }),
                ..Default::default()
            }
            .into(),
            StandardItem {
                label: gettext("Check for updates"),
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
                label: gettext("Exit"),
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

// Starting the Systray Applet
pub async fn run(
    icon_statefile: PathBuf,
    updates_statefile_type: updates_statefiles::UpdatesStateFiles,
    desktop_file: PathBuf,
    i18n_dir: PathBuf,
) {
    // Set gettext domain for translations
    setlocale(LocaleCategory::LcAll, "").expect("Failed to load environment locale");

    textdomain("Arch-Update").expect("Failed to set gettext domain");

    bindtextdomain(
        "Arch-Update",
        i18n_dir.to_str().expect("Unknown or invalid locale path"),
    )
    .expect("Failed to bind gettext domain path");

    // Clone icon statefile path variable (used by the watcher)
    let watcher_icon_statefile = icon_statefile.clone();

    let tray = ArchUpdateTray {
        icon_statefile,
        updates_statefile_type,
        desktop_file,
    };

    // Start the systray applet
    let handle = tray
        .spawn()
        .await
        .expect("Unable to start the systray applet");

    info!("Systray applet started");

    // Rebuild the systray applet on icon statefile content changes
    tokio::spawn(tray_helpers::icon_watcher(
        watcher_icon_statefile,
        handle.clone(),
    ));

    // Run forever
    future::pending().await
}
