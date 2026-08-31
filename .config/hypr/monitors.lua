-- Hyprland owns output modes and scales. The dock hotplug policy in
-- ~/.local/bin/omarchy-auto-dock-monitor toggles the laptop panel.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.049", position = "0x0", scale = 1.333333 })
