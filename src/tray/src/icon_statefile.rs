//! Find the icon statefile containing the systray icon to set depending on the state

use std::env;
use std::fs::File;
use std::io;
use std::path::PathBuf;

pub fn get_icon_statefile() -> io::Result<PathBuf> {
    let state_dir = env::var_os("XDG_STATE_HOME")
        .map(PathBuf::from)
        .or_else(|| env::var_os("HOME").map(|path| PathBuf::from(path).join(".local/state")))
        .ok_or_else(|| io::Error::other("State directory not found"))?
        .join("arch-update");

    let icon_statefile = state_dir.join("tray_icon");

    File::open(&icon_statefile)?;

    Ok(icon_statefile)
}
