#!/bin/bash
if ! playerctl status &>/dev/null; then
    exit 1
fi

TITLE=$(playerctl metadata title 2>/dev/null)
TITLE=${TITLE:0:30}

ARTIST=$(playerctl metadata artist 2>/dev/null)
ICON_MUSIC=""

if [ -n "$ARTIST" ]; then
    echo "$ICON_MUSIC $TITLE - $ARTIST"
else
    echo "$ICON_MUSIC $TITLE"
fi
