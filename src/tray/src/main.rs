//! A systray applet for Arch-Update
//! https://github.com/Antiz96/arch-update
//! SPDX-License-Identifier: GPL-3.0-or-later

use std::process;

mod icon_statefile;
mod updates_statefiles;

fn main() {
    // Get the icon statefile
    let icon_statefile = icon_statefile::get_icon_statefile().unwrap_or_else(|error| {
        eprintln!("Unable to access the icon statefile:\n{error}");
        process::exit(1);
    });

    // Get the updates statefiles
    let (
        updates_statefile,
        updates_statefile_packages,
        updates_statefile_aur,
        updates_statefile_flatpak,
    ) = updates_statefiles::get_updates_statefiles().unwrap_or_else(|error| {
        eprintln!("Unable to access updates statefiles:\n{error}");
        process::exit(1);
    });
}
