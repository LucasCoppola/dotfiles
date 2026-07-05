#!/bin/bash

export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/share/omarchy/bin"

icon=$(omarchy-weather-icon 2>/dev/null)
status=$(omarchy-weather-status 2>/dev/null)

if [[ -n $icon ]]; then
  icon=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
  status=$(printf '%s' "$status" | sed 's/["\\]/\\&/g')
  printf '{"text":"%s","tooltip":"%s"}\n' "$icon" "$status"
else
  printf '{"text":"","class":"unavailable"}\n'
fi
