#!/usr/bin/env bash

# 1. Wait for the swww daemon to fully initialize
while ! swww query >/dev/null 2>&1; do
    sleep 0.1
done

# 2. Loop through all active monitors detected by swww
# This handles the ": HDMI-A-1" format by grabbing the second field
swww query | awk -F: '{print $2}' | xargs | tr ' ' '\n' | while read -r monitor; do
    
    # Define the path to the cached wallpaper for THIS specific monitor
    SAVED_WALL=$(cat "$HOME/.cache/.last_wallpaper_$monitor" 2>/dev/null)
    
    if [ -f "$SAVED_WALL" ]; then
        # Apply the saved wallpaper instantly (no transition for faster boot)
        swww img -o "$monitor" "$SAVED_WALL" --transition-type none
    else
        # Fallback if no specific save exists for this monitor
        swww img -o "$monitor" "$HOME/Pictures/wallpapers/ado2.jpg" --transition-type none
    fi
done
