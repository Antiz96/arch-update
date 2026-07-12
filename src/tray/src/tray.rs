//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use ksni::TrayMethods;
use log::{debug, error, info};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

use crate::updates_statefiles::UpdatesStateFiles;

struct ArchUpdateTray {
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,
    desktop_file: PathBuf,

    selected_option: usize,
    checked: bool,
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
                error!("Cannot set the icon: {error}");
                "dialog-error".into()
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
            Err(error) => error!("Cannot launch Arch-Update: {error}"),
        }
    }

    fn menu(&self) -> Vec<ksni::MenuItem<Self>> {
        use ksni::menu::*;
        vec![
            SubMenu {
                label: "a".into(),
                submenu: vec![
                    SubMenu {
                        label: "a1".into(),
                        submenu: vec![
                            StandardItem {
                                label: "a1.1".into(),
                                ..Default::default()
                            }
                            .into(),
                            StandardItem {
                                label: "a1.2".into(),
                                ..Default::default()
                            }
                            .into(),
                        ],
                        ..Default::default()
                    }
                    .into(),
                    StandardItem {
                        label: "a2".into(),
                        ..Default::default()
                    }
                    .into(),
                ],
                ..Default::default()
            }
            .into(),
            MenuItem::Separator,
            RadioGroup {
                selected: self.selected_option,
                select: Box::new(|this: &mut Self, current| {
                    this.selected_option = current;
                }),
                options: vec![
                    RadioItem {
                        label: "Option 0".into(),
                        ..Default::default()
                    },
                    RadioItem {
                        label: "Option 1".into(),
                        ..Default::default()
                    },
                    RadioItem {
                        label: "Option 2".into(),
                        ..Default::default()
                    },
                ],
                ..Default::default()
            }
            .into(),
            CheckmarkItem {
                label: "Checkable".into(),
                checked: self.checked,
                activate: Box::new(|this: &mut Self| this.checked = !this.checked),
                ..Default::default()
            }
            .into(),
            StandardItem {
                label: "Exit".into(),
                icon_name: "application-exit".into(),
                activate: Box::new(|_| std::process::exit(0)),
                ..Default::default()
            }
            .into(),
        ]
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

        selected_option: 0,
        checked: false,
    };
    let handle = tray.spawn().await.unwrap();

    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    // We can modify the tray
    handle
        .update(|tray: &mut ArchUpdateTray| tray.checked = true)
        .await;
    // Run forever
    std::future::pending().await
}
