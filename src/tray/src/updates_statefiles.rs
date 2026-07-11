//! Find the updates statefile containing the list of pending udpates for each package types

use std::env;
use std::fs::File;
use std::io::{self, Error};
use std::path::PathBuf;

pub struct UpdatesStateFiles {
    pub all: PathBuf,
    pub packages: PathBuf,
    pub aur: PathBuf,
    pub flatpak: PathBuf,
}

pub fn get_updates_statefiles() -> io::Result<UpdatesStateFiles> {
    let paths = [
        env::var_os("XDG_STATE_HOME").map(|path| PathBuf::from(path).join("arch-update")),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/state/arch-update")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| {
            let updates = UpdatesStateFiles {
                all: path.join("last_updates_check"),
                packages: path.join("last_updates_check_packages"),
                aur: path.join("last_updates_check_aur"),
                flatpak: path.join("last_updates_check_flatpak"),
            };

            (File::open(&updates.all).is_ok()
                && File::open(&updates.packages).is_ok()
                && File::open(&updates.aur).is_ok()
                && File::open(&updates.flatpak).is_ok())
            .then_some(updates)
        })
        .ok_or_else(|| Error::other("Unable to access updates statefiles"))
}
