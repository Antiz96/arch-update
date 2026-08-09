//! Set and initialize localization

use anyhow::Context;
use gettextrs::*;
use log::warn;
use std::env;
use std::fs::File;
use std::path::PathBuf;

// Find the directory containing translation files
pub fn get_i18n_dir() -> anyhow::Result<String> {
    let paths = [
        env::var_os("XDG_DATA_HOME").map(|path| PathBuf::from(path).join("locale")),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/share/locale")),
        // Purposely only searching the first XDG_DATA_DIRS entry for simplification
        // This can be updated if this ever becomes an issue
        env::var_os("XDG_DATA_DIRS").map(|path| {
            PathBuf::from(path.to_string_lossy().split(':').next().unwrap_or("")).join("locale")
        }),
        Some(PathBuf::from("/usr/local/share/locale")),
        Some(PathBuf::from("/usr/share/locale")),
    ];

    paths
        .into_iter()
        .flatten()
        .find_map(|path| {
            let translation_file = path.join("fr/LC_MESSAGES/Arch-Update.mo");

            File::open(&translation_file)
                .ok()
                .and_then(|_| path.to_str().map(str::to_owned))
        })
        .context("Failed to access the translation directory")
}

// Initialize localization
pub fn init_i18n(i18n_dir: &str) {
    // Safety: setlocale() is safe to call here because no additional threads have been created
    // at that point (the Tokio runtime is created at a later stage)
    // See https://github.com/gettext-rs/gettext-rs/blob/0.8.0/gettext-sys/lib.rs#L37-L49
    unsafe {
        if setlocale(LocaleCategory::LcMessages, "").is_none() {
            warn!("Unable to load locale environment");
        }
    }

    if textdomain("Arch-Update").is_err() {
        warn!("Unable to set gettext domain");
    }

    if bindtextdomain("Arch-Update", i18n_dir).is_err() {
        warn!("Unable to bind gettext domain path");
    }

    if bind_textdomain_codeset("Arch-Update", "UTF-8").is_err() {
        warn!("Unable to set gettext domain codeset");
    }
}
