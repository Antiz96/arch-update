//! Find the updates statefile containing the list of pending udpates for each package types

use std::env;
use std::fs::File;
use std::io;
use std::path::PathBuf;

pub fn get_updates_statefiles() -> io::Result<(PathBuf, PathBuf, PathBuf, PathBuf)> {
    let state_dir = env::var_os("XDG_STATE_HOME")
        .map(PathBuf::from)
        .or_else(|| env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/state")))
        .ok_or_else(|| io::Error::other("State directory not found"))?
        .join("arch-update");

    let updates_statefile = state_dir.join("last_updates_check");
    let updates_statefile_packages = state_dir.join("last_updates_check_packages");
    let updates_statefile_aur = state_dir.join("last_updates_check_aur");
    let updates_statefile_flatpak = state_dir.join("last_updates_check_flatpak");

    File::open(&updates_statefile)?;

    Ok((
        updates_statefile,
        updates_statefile_packages,
        updates_statefile_aur,
        updates_statefile_flatpak,
    ))
}
