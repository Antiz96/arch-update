//! Watch for the icon statefile, allowing to trigger a dynammic rebuild of the systray applet on
//! icon change

use ksni::Handle;
use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use std::path::PathBuf;
use tokio::sync::mpsc;

pub async fn watch(icon_statefile: PathBuf, handle: Handle<crate::tray::ArchUpdateTray>) {
    let (tx, mut rx) = mpsc::unbounded_channel();

    let mut watcher = RecommendedWatcher::new(
        move |result| {
            let _ = tx.send(result);
        },
        Config::default(),
    )
    .expect("Unable to create icon statefile watcher");

    watcher
        .watch(&icon_statefile, RecursiveMode::NonRecursive)
        .expect("Unable to watch icon statefile");

    while let Some(Ok(event)) = rx.recv().await {
        if matches!(event.kind, EventKind::Modify(_)) {
            handle.update(|_| {}).await;
        }
    }
}
