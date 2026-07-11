//! Find the directory containing translation files

use std::env;
use std::fs::File;
use std::io::{self, Error};
use std::path::PathBuf;

pub fn get_i18n_dir() -> io::Result<PathBuf> {
    let paths = [
        env::var_os("XDG_DATA_HOME").map(|path| PathBuf::from(path).join("locale")),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/share/locale")),
        // Purposely only searching the first XDG_DATA_DIRS entry for simplification
        // This can be updated if this ever becomes an issue
        env::var_os("XDG_DATA_DIRS").map(|path| {
            PathBuf::from(path.to_string_lossy().split(':').next().unwrap()).join("locale")
        }),
        Some(PathBuf::from("/usr/local/share/locale")),
        Some(PathBuf::from("/usr/share/locale")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| {
            let translation_file = path.join("fr/LC_MESSAGES/Arch-Update.mo");

            File::open(&translation_file).ok().map(|_| path)
        })
        .ok_or_else(|| Error::other("Unable to access the translation directory"))
}
