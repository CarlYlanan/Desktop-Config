#!/usr/bin/env bash

# 1. Setup temp files
tmp_dir="/tmp/waybar-media"
mkdir -p "$tmp_dir"
art_path="$tmp_dir/cover.png"

# 2. Gather Metadata
metadata=$(playerctl metadata --format "{{mpris:artUrl}}|{{title}}|{{artist}}")
IFS="|" read -r art_url title artist <<< "$metadata"

# 3. Fetch Album Art
if [[ "$art_url" == http* ]]; then
    fixed_url=$(echo "$art_url" | sed 's|http://googleusercontent.com/spotify.com/|https://i.scdn.co/|')
    curl -s "$fixed_url" > "$art_path"
else
    # Create a solid color fallback if curl fails or no art
    art_path="audio-x-generic"
fi

# 4. Define Buttons (Symbol + Clear Label to prevent stretching)
# Using ' - ' helps Rofi treat these as distinct list items
opts="󰐊 Play / Pause\n󰒮 Previous\n󰒭 Next\n󰝟 Mute\n󰝝 Unmute\n󰒝 Shuffle Toggle\n󰑖 Repeat Toggle"

# 5. Launch Rofi
# We are using a simpler vertical layout that is guaranteed not to break.
chosen=$(echo -e "$opts" | rofi -dmenu \
    -p "Spotify" \
    -mesg "<b>$artist</b>\n$title" \
    -me-select-entry "" \
    -me-accept-entry "MousePrimary" \
    -theme-str "
        * {
            background: #0F1117;
            background-alt: #1A1B26;
            foreground: #ECEFF4;
            selected: #00BEBE;
            active: #FF4D6D;
        }
        window {
            width: 400px;
            border: 2px;
            border-color: @active;
            border-radius: 12px;
            background-color: @background;
        }
        mainbox {
            children: [ \"message\", \"listview\" ];
            padding: 15px;
        }
        message {
            margin: 0 0 10px 0;
            padding: 10px;
            border: 1px;
            border-color: @selected;
            border-radius: 8px;
            background-color: @background-alt;
        }
        textbox {
            text-color: @foreground;
            horizontal-align: 0.5;
            font: \"JetBrainsMono Nerd Font 12\";
        }
        listview {
            fixed-height: false;
            dynamic: true;
            scrollbar: false;
            lines: 7;
            spacing: 5px;
        }
        element {
            padding: 8px 15px;
            border-radius: 8px;
            background-color: @background-alt;
        }
        element-text {
            font: \"JetBrainsMono Nerd Font 13\";
            text-color: @foreground;
        }
        element selected {
            background-color: @selected;
        }
        element-text selected {
            text-color: #0F1117;
        }
        inputbar { enabled: false; }
    ")

# 6. Action Logic
case "$chosen" in
    *"Play"*) playerctl play-pause ;;
    *"Previous"*) playerctl previous ;;
    *"Next"*) playerctl next ;;
    *"Mute"*) playerctl volume 0 ;;
    *"Unmute"*) playerctl volume 0.5 ;;
    *"Shuffle"*) playerctl shuffle Toggle ;;
    *"Repeat"*) playerctl loop Track ;;
esac
