//! Find the updates statefile containing the list of pending udpates for each package types

use std::env;
use std::fs::File;
use std::io::{self, Error};
use std::path::PathBuf;

pub fn get_updates_statefiles() -> io::Result<(PathBuf, PathBuf, PathBuf, PathBuf)> {
    let paths = [
        env::var_os("XDG_STATE_HOME").map(|path| PathBuf::from(path).join("arch-update")),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/state/arch-update")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| {
            let updates_statefile = path.join("last_updates_check");
            let updates_statefile_packages = path.join("last_updates_check_packages");
            let updates_statefile_aur = path.join("last_updates_check_aur");
            let updates_statefile_flatpak = path.join("last_updates_check_flatpak");

            (File::open(&updates_statefile).is_ok()
                && File::open(&updates_statefile_packages).is_ok()
                && File::open(&updates_statefile_aur).is_ok()
                && File::open(&updates_statefile_flatpak).is_ok())
            .then_some((
                updates_statefile,
                updates_statefile_packages,
                updates_statefile_aur,
                updates_statefile_flatpak,
            ))
        })
        .ok_or_else(|| Error::other("Unable to access updates statefiles"))
}
