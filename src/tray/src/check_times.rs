//! Get last check and calculate next check for the related menu entries in the systray applet

use serde::Deserialize;
use std::fs;
use std::path::Path;
use std::process::Command;
use std::thread::sleep;
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

// Wrapper around the "read_last_check" function including a grace period (retry each 200ms up to 2s)
// This is to avoid logging useless and noisy warnings about the check_time statefile not being
// accessible in the short window of time where it gets briefly emptied as it is being re-written
// during a check for updates
pub fn get_last_check(updates_statefile_time: &Path) -> Option<String> {
    for _ in 0..10 {
        if let Some(check_time) = read_last_check(updates_statefile_time) {
            return Some(check_time);
        }

        sleep(Duration::from_millis(200));
    }

    None
}

fn read_last_check(updates_statefile_time: &Path) -> Option<String> {
    let check_time = fs::read_to_string(updates_statefile_time)
        .ok()?
        .lines()
        .next()?
        .parse::<u64>()
        .ok()?;
    let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?;
    let past_time = now.checked_sub(Duration::from_secs(check_time))?;

    format_time(past_time)
}

fn format_time(time: Duration) -> Option<String> {
    let mut parts = Vec::new();

    let days = time.as_secs() / 86400;
    let hours = (time.as_secs() % 86400) / 3600;
    let minutes = (time.as_secs() % 3600) / 60;
    let seconds = time.as_secs() % 60;

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
