# Shared workspaces across docking

This machine uses external-only displays when docked and the laptop panel when
undocked (`~/.local/bin/omarchy-auto-dock-monitor`). It should have one shared
desktop: terminal on workspace 1, browser on 2, Spotify on 3, with Alt+Q/W/E/R/T
and the existing dot widget pointing at those same workspaces on either display.

Omarchy 4.5 instead assigns each physical monitor a block of ten workspace IDs.
Its unplug handler renumbered workspace 1 to 22 and workspace 2 to 23 on this
machine. The custom keys, app-placement rules and dots still referred to global
IDs 1–5, hiding the originals and making newly opened apps look like replacements.

`hyprland.lua` installs a Lua module preload for `default.hypr.monitor-workspaces`
**before** requiring Omarchy's defaults. `shared-workspaces.lua` implements the
workspace helper API used by default bindings, but does not register renumbering
hooks. Hyprland still transfers workspaces off a disconnected/disabled monitor.

No packaged files are edited. The old monitor-workspace state files are unused
in shared mode. The global-ID dot widget and fixed app-placement rules are
intentional; don't replace the dots with the stock per-monitor widget without
also reconsidering this policy.

## Checks

```sh
lua ~/.config/hypr/shared-workspaces.test.lua
hyprctl reload
hyprctl configerrors
hyprctl repl 'o.workspaces.shared' # true
```

The Lua tests use fake displays and temporary state, not the running desktop.
They also check that all workspace methods used by the installed default tiling
bindings exist, to flag interface changes after future Omarchy updates.

For a real dock/undock check, record window addresses and workspace IDs with
`hyprctl -j clients`, reconnect/disconnect the display, and verify the same
windows remain on 1/2 rather than being renumbered. Do not reopen missing apps
before capturing the state.

To return to per-monitor workspaces, remove the preload block from
`hyprland.lua` and reload; the ordinary Omarchy module will load again. Its
numbering model then requires matching shortcuts, window placement and dots.
