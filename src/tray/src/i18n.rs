//! Set and initialize localization

use gettextrs::*;
use log::warn;
use std::env;
use std::fs::File;
use std::path::PathBuf;

// Supersede default gettext bindtextdomain if needed (for instance if a different installation PREFIX
// than "/usr/share" was used)
pub fn get_i18n_dir() -> String {
    let paths = [
        env::var_os("XDG_DATA_HOME").map(|path| PathBuf::from(path).join("locale")),
        env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/share/locale")),
        // Purposely only searching the first XDG_DATA_DIRS entry for simplification
        // This can be updated if this ever becomes an issue
        env::var_os("XDG_DATA_DIRS").map(|path| {
            PathBuf::from(path.to_string_lossy().split(':').next().unwrap_or("")).join("locale")
        }),
        Some(PathBuf::from("/usr/local/share/locale")),
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
        .unwrap_or_else(|| String::from("/usr/share/locale"))
}

// Initialize localization
pub fn init_i18n(i18n_dir: &str) {
    // Safety: setlocale() is safe to call here because no additional threads have been created
    // at that point (the Tokio runtime is created at a later stage)
    // See https://github.com/gettext-rs/gettext-rs/blob/0.8.0/gettext-sys/lib.rs#L37-L49
    unsafe {
        if setlocale(LocaleCategory::LcMessages, "").is_none() {
            warn!("Failed to load locale environment");
        }
    }

    if textdomain("Arch-Update").is_err() {
        warn!("Failed to set gettext domain");
    }

    if bindtextdomain("Arch-Update", i18n_dir).is_err() {
        warn!("Failed to bind gettext domain path");
    }

    if bind_textdomain_codeset("Arch-Update", "UTF-8").is_err() {
        warn!("Failed to set gettext domain codeset");
    }
}
