use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
use std::path::PathBuf;

pub async fn watch(icon_statefile: PathBuf, handle: ksni::Handle<crate::tray::ArchUpdateTray>) {
    let (tx, mut rx) = tokio::sync::mpsc::unbounded_channel();

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
