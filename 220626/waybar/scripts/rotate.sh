#!/bin/bash
CONFIG_PATH="$HOME/.config/niri/config.kdl"

# Check if the transform line is currently commented out (meaning we are currently in 'norm' mode)
if grep -q '^[[:space:]]*\/\/.*transform "270"' "$CONFIG_PATH"; then
    # --- SWITCH TO VERTICAL ---
    # 1. Uncomment Niri monitor transform
    sed -i '/output "Microstep G274QPX/,/}/ {s|//[[:space:]]*transform "270"|transform "270"|}' "$CONFIG_PATH"

    # 2. Update OBS with half-second pauses
    obs-cmd replay stop
    sleep 0.5
    obs-cmd profile switch vert
    sleep 0.5
    obs-cmd scene switch vert
    sleep 0.5
    obs-cmd replay start
else
    # --- SWITCH TO NORMAL ---
    # 1. Comment out Niri monitor transform
    sed -i '/output "Microstep G274QPX/,/}/ {s|transform "270"|//    transform "270"|}' "$CONFIG_PATH"

    # 2. Update OBS with half-second pauses
    obs-cmd replay stop
    sleep 0.5
    obs-cmd profile switch norm
    sleep 0.5
    obs-cmd scene switch norm
    sleep 0.5
    obs-cmd replay start
fi

# Reload Niri immediately to see changes
niri msg reload
