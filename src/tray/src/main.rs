//! arch-update-tray - A systray applet for Arch-Update
//! https://github.com/Antiz96/arch-update
//! SPDX-License-Identifier: GPL-3.0-or-later

use log::error;
use std::process;

mod check_times;
mod desktop_file;
mod i18n_dir;
mod icon_statefile;
mod statefile_watcher;
mod tray;
mod updates_statefiles;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    // Initialize logger
    env_logger::init();

    // Get the icon statefile
    let icon_statefile = icon_statefile::get_icon_statefile().unwrap_or_else(|error| {
        error!("{error}");
        process::exit(1);
    });

    // Get the updates statefiles
    let updates_statefiles = updates_statefiles::get_updates_statefiles().unwrap_or_else(|error| {
        error!("{error}");
        process::exit(1);
    });

    // Get the desktop file
    let desktop_file = desktop_file::get_desktop_file().unwrap_or_else(|error| {
        error!("{error}");
        process::exit(1);
    });

    // Get the translation directory
    let i18n_dir = i18n_dir::get_i18n_dir().unwrap_or_else(|error| {
        error!("{error}");
        process::exit(1);
    });

    // Start systray applet
    tray::run(icon_statefile, updates_statefiles, desktop_file, i18n_dir).await;
}
