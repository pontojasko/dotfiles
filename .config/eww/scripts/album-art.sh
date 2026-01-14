#!/bin/bash

art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)



if [ -n "$art_url" ]; then
    art_path="${art_url#file://}"
    echo "$art_path"
else
    echo "$HOME/.config/eww/default-cover.png"
fi
