# Lucas Dashboard

Personal Omarchy bar dashboard opened from the Arch icon.

## Contents

- Weather from `wttr.in`, using the location managed by `omarchy-weather-location`
- CPU, temperature, load, and memory from Linux `/proc` and thermal sysfs
- Codex session and weekly allowance remaining from the Omarchy usage record

## Interactions

- Left-click the Arch icon: toggle the dashboard
- Right-click: open a terminal
- Middle-click or `R` while open: refresh
- Click the System card: open `btop`
- Escape: close

System data refreshes every five seconds only while the panel is open. Weather
and Codex limits refresh once at shell startup and whenever the panel opens.

The data adapters are in `scripts/`. `scripts/codex-usage-update` handles the
approval-policy mismatch between Omarchy 4.0.1 and Codex 0.149.1.
