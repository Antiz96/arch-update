//! arch-update-tray - A systray applet for Arch-Update
//! https://github.com/Antiz96/arch-update
//! SPDX-License-Identifier: GPL-3.0-or-later

use log::error;
use std::process;

mod desktop_file;
mod i18n;
mod icon_statefile;
mod tray;
mod tray_helpers;
mod updates_statefiles;

fn main() {
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

    // Get the translation directory and initialize localization
    let i18n_dir = i18n::get_i18n_dir().unwrap_or_else(|error| {
        error!("{error}");
        process::exit(1);
    });
    i18n::init_i18n(&i18n_dir);

    // Create single-threaded tokio runtime and start the systray applet
    tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("Failed to create Tokio runtime")
        .block_on(tray::run(icon_statefile, updates_statefiles, desktop_file));
}
