#!/bin/bash

if eww active-windows | grep -q "spotify_control"; then
    eww close spotify_control
    hyprctl dispatch submap reset
else
    eww open spotify_control
    hyprctl dispatch submap spotify_menu
fi
