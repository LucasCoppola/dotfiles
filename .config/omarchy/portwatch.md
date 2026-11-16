# Portwatch integration

The bar entry and `Super+Alt+P` shortcut expect the separately maintained Portwatch project at `~/code/portwatch`. Its deployed plugin copy is installer-managed and intentionally ignored by this dotfiles repository.

From that checkout, build and install it with the project's documented commands:

```sh
cargo build --release --manifest-path backend/Cargo.toml
python scripts/install-omarchy-panel.py --enable --restart-shell
```

The installer deploys `manifest.json` and `qml/` into `~/.config/omarchy/plugins/portwatch.panel/`. It enables the bar entry and sets the backend path. Use it only when intentionally installing: restarting the shell closes open shell panels. For later updates, omit `--enable` to preserve placement and settings.

This machine's `shell.json` points to `/home/lucas/code/portwatch/backend/target/release/portwatch`, not a system-installed executable. On another machine or under a different username, install from the new checkout and let the installer set that path; do not assume the committed absolute path is portable. The executable and deployed UI are not included in dotfiles.

Edit Portwatch's own source and redeploy rather than changing or committing its installed plugin copy here. Building, installing and restarting were not performed as part of the dotfiles commit cleanup.
