//! Find the desktop file needed to run Arch-Update from the terminal

use std::env;
use std::fs::File;
use std::io::{self, Error};
use std::path::PathBuf;

pub fn get_desktop_file() -> io::Result<PathBuf> {
    let paths = [
        env::var_os("XDG_DATA_HOME")
            .map(|path| PathBuf::from(path).join("applications/arch-update.desktop")),
        env::var_os("HOME")
            .map(|path| PathBuf::from(path).join(".local/share/applications/arch-update.desktop")),
        // Purposely only searching the first XDG_DATA_DIRS entry for simplification
        // This can be updated if this ever becomes an issue
        env::var_os("XDG_DATA_DIRS").map(|path| {
            PathBuf::from(
                path.to_string_lossy()
                    .split(':')
                    .next()
                    .expect("Unable to get the first XDG_DATA_DIRS entry"),
            )
            .join("applications/arch-update.desktop")
        }),
        Some(PathBuf::from(
            "/usr/local/share/applications/arch-update.desktop",
        )),
        Some(PathBuf::from("/usr/share/applications/arch-update.desktop")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| File::open(&path).ok().map(|_| path))
        .ok_or_else(|| Error::other("Unable to access the desktop file"))
}
