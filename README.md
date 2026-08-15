# Dotfiles

Personal Linux/Omarchy and macOS configuration. This repository is tailored to my machines; individual files may be useful as references, but the setup is not intended to be copied or installed wholesale.

## Omarchy Quattro

The active desktop configuration uses Quattro's supported interfaces:

- Hyprland Lua overrides in `.config/hypr/*.lua`
- Omarchy Shell configuration in `.config/omarchy/shell.json`
- User-owned clock, indicator, and workspace plugins in `.config/omarchy/plugins/`
- Custom Arch menu, CPU, and memory modules in `.config/omarchy/bar/`
- Monitor profiles in `.config/kanshi/config`
- Global monospace selection in `.config/fontconfig/fonts.conf`

Legacy Hyprland `.conf` overrides, Hyprlock, and Waybar are intentionally not included. `hypridle.conf`, `hyprsunset.conf`, and `xdph.conf` remain because they are consumed by separate processes rather than Hyprland's Lua configuration.

### Idle and lock policy

This setup intentionally has no password-protected session lock:

- Omarchy's `omarchy.idle` and `omarchy.lock` plugins are disabled in `shell.json`.
- `hypridle.service` is started from `autostart.lua`.
- The display turns off after 10 minutes and the machine suspends after one hour.
- Active audio/video postpones both actions.
- The Omarchy suspend-lock service is disabled from `autostart.lua`.
- Lock actions open a dismissible screensaver instead.

This means the session is **not secured while suspended**.

### Machine-specific display settings

The current Kanshi profile expects:

- Laptop display: `eDP-1`, `1920x1080@60.049`, scale `1.333333`
- USB-C display: `DP-1`, `1920x1080@60`, scale `1.0`

These output names and modes are machine-specific. Hyprland's generic `monitors.lua` remains the fallback.

## Validation

After desktop changes:

```bash
hyprctl reload
hyprctl configerrors
omarchy restart shell
```
