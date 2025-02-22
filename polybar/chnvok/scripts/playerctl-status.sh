#!/bin/bash
if ! playerctl status &>/dev/null; then
    exit 1
fi

if ! playerctl -l | grep -q "spotify"; then
    exit 1
fi

playerctl -p spotify metadata &>/dev/null || exit 1

TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
TITLE=${TITLE:0:30}
ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
ICON_MUSIC=""

if [ -n "$ARTIST" ]; then
    echo "$ICON_MUSIC $TITLE - $ARTIST"
else
    echo "$ICON_MUSIC $TITLE"
fi
