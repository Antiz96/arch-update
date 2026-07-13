//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use ksni::TrayMethods;
use ksni::menu::*;
use log::{debug, error, info, warn};
use std::fs;
use std::future;
use std::path::PathBuf;
use std::process::{self, Command};

use crate::check_times::{get_last_check, get_next_check};
use crate::icon_statefile_watcher;
use crate::updates_statefiles::UpdatesStateFiles;

pub struct ArchUpdateTray {
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,
}

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
    // We ignore the "zombie_processes" clippy warning as we intentionally do not wait for the `gio`
    // launcher process, as the systray applet remain independent from the launched application
    #[allow(clippy::zombie_processes)]
    fn activate(&mut self, _x: i32, _y: i32) {
        match Command::new("gio")
            .arg("launch")
            .arg(&self.desktop_file)
            .spawn()
        {
            Ok(_) => info!("Arch-Update launched"),
            Err(error) => error!("Unable to launch Arch-Update: {error}"),
        }
    }

    fn menu(&self) -> Vec<ksni::MenuItem<Self>> {
        // Borrowed by the "Run Arch-Update" button
        let desktop_file = self.desktop_file.clone();

        // Initialize the vector for the menu entries
        let mut menu = Vec::new();

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

        // Add a menu group containing a separator and the "Run Arch-Update", "Check for updates" and "Exit" buttons
        menu.extend([
            MenuItem::Separator,
            StandardItem {
                label: "Run Arch-Update".into(),
                activate: Box::new(move |_| {
                    match Command::new("gio").arg("launch").arg(&desktop_file).spawn() {
                        Ok(_) => info!("Arch-Update launched"),
                        Err(error) => error!("Unable to launch Arch-Update: {error}"),
                    }
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

pub async fn run(
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,
    i18n_dir: PathBuf,
) {
    // Borrowed icon_statefile var used by the watcher
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

    // Update the systray applet on icon statefile content changes
    tokio::spawn(icon_statefile_watcher::watch(
        watcher_icon_statefile,
        handle.clone(),
    ));

    // Run forever
    future::pending().await
}
