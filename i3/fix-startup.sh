#!/bin/bash

# Wait until X is ready
while [ -z "$DISPLAY" ] || ! xinput list &>/dev/null; do
    sleep 0.5
done

# Wait up to 5s for mouse to appear (non-blocking fallback)
for i in {1..10}; do
    if xinput list | grep -q "Logitech G203 LIGHTSYNC Gaming Mouse"; then
        break
    fi
    sleep 0.5
done

# Set Caps to Escape
setxkbmap -option caps:escape

# Disable screen blanking / DPMS
xset s off
xset -dpms
xset s noblank

# Set mouse accel if mouse found
if xinput list | grep -q "Logitech G203 LIGHTSYNC Gaming Mouse"; then
    xinput set-prop "Logitech G203 LIGHTSYNC Gaming Mouse" "libinput Accel Speed" -1
fi

# Set touchpad natural scrolling off (dynamic lookup)
TOUCHPAD_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d= -f2)
if [ -n "$TOUCHPAD_ID" ]; then
    xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 0
fi
