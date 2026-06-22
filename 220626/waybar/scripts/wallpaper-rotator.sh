#!/usr/bin/env bash

WALLPAPER_DIR="/home/carly/Pictures/git/Desktop-Config/wallpapers"
INTERVAL=1800 # 30 minutes in seconds

change_wallpapers() {
    # Get active monitors
    MONITORS=$(awww query | awk '{print $1}' | tr -d ':')

    # Read all wallpapers from the main folder into an array
    mapfile -t ALL_WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

    # Shuffle the array elements completely
    SHUFFLED=($(shuf -e "${ALL_WALLPAPERS[@]}"))

    i=0
    for MONITOR in $MONITORS; do
        # Assign a unique image from the shuffled pool to each screen
        RANDOM_WALLPAPER="${SHUFFLED[$i]}"

        if [ -n "$RANDOM_WALLPAPER" ]; then
            awww img -o "$MONITOR" "$RANDOM_WALLPAPER" --transition-type grow --transition-pos 0.85,0.97 --transition-duration 1.5
        fi
        ((i++))
    done
}

# 1. Run immediately on execution (Startup)
change_wallpapers

# 2. Loop and wait for intervals
while true; do
    sleep "$INTERVAL"
    change_wallpapers
done
