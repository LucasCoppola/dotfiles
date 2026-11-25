-- Personal bindings ported from the pre-Quattro Hyprland config.
-- Omarchy's defaults remain available unless one of these bindings overrides it.

-- Prefer personal SUPER bindings over conflicting Omarchy defaults.
hl.unbind("SUPER + F") -- was: Full screen
hl.unbind("SUPER + S") -- was: Toggle scratchpad
hl.unbind("SUPER + W") -- was: Close window
hl.unbind("SUPER + L") -- was: Toggle workspace layout
hl.unbind("SUPER + SPACE") -- was: Omarchy menu
hl.unbind("SUPER + ESCAPE") -- was: System menu
hl.unbind("SUPER + ALT + SPACE") -- was: Apps menu
hl.unbind("SUPER + SHIFT + B") -- was: Browser
hl.unbind("SUPER + SHIFT + C") -- was: Calendar
hl.unbind("SUPER + SHIFT + E") -- was: Email
hl.unbind("SUPER + CTRL + L") -- was: Password-protected lock
hl.unbind("switch:on:Lid Switch") -- was: Lock on lid close

-- Keep the old choice to disable Omarchy's numbered workspace bindings.
for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	hl.unbind("SUPER + " .. key)
	hl.unbind("SUPER + SHIFT + " .. key)
end

-- Applications.
o.bind("ALT + RETURN", "Ghostty", 'uwsm-app -- ghostty --working-directory="$(omarchy-cmd-terminal-cwd)" -e herdr')
o.bind("SUPER + F", "File manager", { launch = "nautilus --new-window" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + M", "Music", "omarchy-launch-or-focus spotify")
o.bind("SUPER + ALT + P", "Toggle Portwatch", "omarchy-shell portwatch.panel toggle")
o.bind(
	"SUPER + SHIFT + E",
	"English class",
	'url_file="$HOME/.config/hypr/private/english-class-url"; '
		.. 'if [ -s "$url_file" ]; then xdg-open "$(cat "$url_file")"; '
		.. "else notify-send -u critical 'English class' 'Missing private URL file'; fi"
)
o.bind("SUPER + SHIFT + C", "Claude", { webapp = "https://claude.com/" })
o.bind("SUPER + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- Window and system controls.
o.bind("ALT + SHIFT + F", "Force full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("ALT + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("ALT + S", "Suspend", "systemctl suspend")
o.bind("ALT + X", "Close window", hl.dsp.window.close())
o.bind("SUPER + CTRL + L", "Passwordless screen", "omarchy-launch-screensaver force")
o.bind("switch:on:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })
o.bind("SUPER + S", "Screenshot region", "omarchy capture screenshot region slurp copy")
-- Keep dictation off the app launcher and AltGr; use one dedicated toggle.
hl.unbind("ALT + Alt_R")
o.rebind("ALT + SPACE", "Apps", "omarchy-menu toggle apps")
o.rebind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
o.bind("ALT + P", "System menu", "omarchy-menu toggle system")
-- Select all stays on the application's Ctrl+A, not the menu shortcut.
o.rebind("SUPER + A", "Omarchy menu", "omarchy-menu toggle")

-- Vim-style focus and window movement.
local directions = {
	H = "l",
	J = "d",
	K = "u",
	L = "r",
}
for key, direction in pairs(directions) do
	o.bind("ALT + " .. key, "Focus " .. direction, hl.dsp.focus({ direction = direction }))
	o.bind("ALT + SHIFT + " .. key, "Move window " .. direction, hl.dsp.window.swap({ direction = direction }))
end

-- QWERT workspaces 1-5 share the same IDs on laptop and external displays.
local workspace_keys = { "Q", "W", "E", "R", "T" }
for workspace, key in ipairs(workspace_keys) do
	o.bind("ALT + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))
	o.bind(
		"ALT + SHIFT + " .. key,
		"Move window to workspace " .. workspace,
		o.workspaces.move_window(workspace)
	)
end

-- Horizontal resizing.
o.bind("ALT + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("ALT + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
