//! A systray applet for Arch-Update
//! https://github.com/Antiz96/arch-update
//! SPDX-License-Identifier: GPL-3.0-or-later

use std::process;

mod icon_statefile;

fn main() {
    // Get the icon statefile
    let icon_statefile = icon_statefile::get_icon_statefile().unwrap_or_else(|error| {
        eprintln!("Unable to access the icon statefile:\n{error}");
        process::exit(1);
    });
}
