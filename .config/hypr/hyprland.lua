-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Personal window placement from the pre-Quattro config. These use Omarchy's
-- current window-rule helper and load after the packaged defaults.
o.window("^com[.]mitchellh[.]ghostty$", { workspace = "1" })
o.window("^zen$", { workspace = "2" })
o.window("^Spotify$", { workspace = "3" })

-- Keep personal windows fully opaque rather than the subtle Quattro default.
o.window({ tag = "default-opacity" }, { opacity = "1 1" })
