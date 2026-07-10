//! Find the directory containing translation files

use std::env;
use std::io;
use std::path::PathBuf;

pub fn get_i18n_dir() -> io::Result<PathBuf> {
    let paths = [
        env::var_os("XDG_DATA_HOME").map(PathBuf::from),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/share")),
        env::var_os("XDG_DATA_DIRS")
            .map(|path| PathBuf::from(path.to_string_lossy().split(':').next().unwrap())),
        Some(PathBuf::from("/usr/local/share")),
        Some(PathBuf::from("/usr/share")),
    ];

    paths
        .into_iter()
        .flatten()
        .map(|path| {
            let locale_dir = path.join("locale");
            let translation_file = locale_dir.join("fr/LC_MESSAGES/Arch-Update.mo");

            if translation_file.is_file() {
                Ok(locale_dir)
            } else {
                Err(io::Error::from(io::ErrorKind::Other))
            }
        })
        .find(Result::is_ok)
        .unwrap_or_else(|| Err(io::Error::from(io::ErrorKind::Other)))
}
