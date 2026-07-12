//! Get last check and calculate next check for the related menu entries in the systray applet

use serde::Deserialize;
use std::fs;
use std::path::Path;
use std::process::Command;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

#[derive(Deserialize)]
struct SystemdTimer {
    next: Option<u64>,
}

pub fn get_next_check() -> Option<String> {
    let systemctl_output = Command::new("systemctl")
        .args(["--user", "list-timers", "arch-update.timer", "-o", "json"])
        .output()
        .ok()?;

    if !systemctl_output.status.success() {
        return None;
    }

    let timers: Vec<SystemdTimer> = serde_json::from_slice(&systemctl_output.stdout).ok()?;
    let next_run = timers.first()?.next?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?;
    let remaining_time = Duration::from_micros(next_run).checked_sub(now)?;

    format_time(remaining_time)
}

pub fn get_last_check(updates_statefile: &Path) -> Option<String> {
    let mtime = fs::metadata(updates_statefile).ok()?.modified().ok()?;
    let past_time = mtime.elapsed().ok()?;

    Some(format_time(past_time))
}

fn format_time(remaining_time: Duration) -> Option<String> {
    let mut parts = Vec::new();

    let days = remaining_time.as_secs() / 86400;
    let hours = (remaining_time.as_secs() % 86400) / 3600;
    let minutes = (remaining_time.as_secs() % 3600) / 60;
    let seconds = remaining_time.as_secs() % 60;

    if days > 0 {
        parts.push(format!("{days}d"));
    }
    if hours > 0 {
        parts.push(format!("{hours}h"));
    }
    if minutes > 0 {
        parts.push(format!("{minutes}m"));
    }
    if seconds > 0 {
        parts.push(format!("{seconds}s"));
    }

    if parts.is_empty() {
        None
    } else {
        Some(parts.join(" "))
    }
}
