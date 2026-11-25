-- Personal startup applications and session policy.
-- Hyprland owns per-output scales; this policy selects external-only or laptop-only.
o.exec_on_start("$HOME/.local/bin/omarchy-auto-dock-monitor")

-- Keep Quattro's secure suspend lock disabled and run the old idle policy
-- through hypridle. Both commands are idempotent, so a fresh machine gets the
-- intended behavior without a separate Omarchy setup script.
o.exec_on_start("systemctl --user disable --now omarchy-sleep-lock.service")
o.exec_on_start("systemctl --user start hypridle.service")

o.launch_on_start("zen-browser")
