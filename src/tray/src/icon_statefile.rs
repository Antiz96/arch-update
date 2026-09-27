//! Find the icon statefile containing the systray icon to set depending on the state

use anyhow::Context;
use std::env;
use std::fs::File;
use std::path::PathBuf;

pub fn get_icon_statefile() -> anyhow::Result<PathBuf> {
    let paths = [
        env::var_os("XDG_STATE_HOME").map(|path| PathBuf::from(path).join("arch-update/tray_icon")),
        env::var_os("HOME")
            .map(|path| PathBuf::from(path).join(".local/state/arch-update/tray_icon")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| File::open(&path).ok().map(|_| path))
        .context("Failed to access the icon statefile")
}
