-- Kanshi owns the per-profile monitor layout. This fallback matches the
-- laptop profile while Kanshi starts.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.333333

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
