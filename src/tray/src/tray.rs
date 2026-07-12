//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use ksni::TrayMethods;
use log::{debug, error, info, warn};
use std::fs;
use std::path::PathBuf;
use std::process::{self, Command};

use crate::check_times::{get_last_check, get_next_check};
use crate::updates_statefiles::UpdatesStateFiles;

struct ArchUpdateTray {
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
        use ksni::menu::*;

        // Borrowed by the "Run Arch-Update" button
        let desktop_file = self.desktop_file.clone();

        // Vector for the menu entries
        let mut menu = Vec::new();

        // Add menu group containing the "Last Check" and "Next check" entries (and a separator)
        match get_next_check() {
            Some(next_check) => {
                menu.extend([
                    StandardItem {
                        label: format!("Next check in {next_check}"),
                        enabled: false,
                        ..Default::default()
                    }
                    .into(),
                    MenuItem::Separator,
                ]);
            }
            None => {
                warn!("Unable to determine next Arch-Update check time");
            }
        }

        // "Run Arch-Update" button
        menu.push(
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
        );
        // "Check for updates" button
        menu.push(
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
        );
        // "Exit" button
        menu.push(
            StandardItem {
                label: "Exit".into(),
                activate: Box::new(|_| {
                    info!("Exited on user request");
                    process::exit(0);
                }),
                ..Default::default()
            }
            .into(),
        );
        menu
    }
}

pub async fn run(
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,
    i18n_dir: PathBuf,
) {
    let tray = ArchUpdateTray {
        icon_statefile,
        updates_statefiles,
        desktop_file,
    };
    let handle = tray.spawn().await.unwrap();

    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    // We can modify the tray
    handle;
    // Run forever
    std::future::pending().await
}
