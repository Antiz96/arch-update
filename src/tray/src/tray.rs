//! Systray applet implementation
//! Built with ksni, inspired / based on the systray example at
//! https://github.com/iovxw/ksni#example

use ksni::TrayMethods;
use std::fs;
use std::path::PathBuf;

use crate::updates_statefiles::UpdatesStateFiles;

struct ArchUpdateTray {
    icon_statefile: PathBuf,
    updates_statefiles: UpdatesStateFiles,

    selected_option: usize,
    checked: bool,
}

impl ksni::Tray for ArchUpdateTray {
    fn id(&self) -> String {
        "Arch-Update".into()
    }
    fn icon_name(&self) -> String {
        fs::read_to_string(&self.icon_statefile)
            .expect("Cannot access icon statefile")
            .trim()
            .to_owned()
    }
    fn title(&self) -> String {
        "Arch-Update".into()
    }
    fn tool_tip(&self) -> ksni::ToolTip {
        ksni::ToolTip {
            title: "Arch-Update".into(),
            ..Default::default()
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
    i18n_dir: PathBuf,
) {
    let tray = ArchUpdateTray {
        icon_statefile,
        updates_statefiles,
        selected_option: 0,
        checked: false,
    };
    let handle = tray.spawn().await.unwrap();

    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    // We can modify the tray
    handle.update(|tray: &mut ArchUpdateTray| tray.checked = true).await;
    // Run forever
    std::future::pending().await
}
