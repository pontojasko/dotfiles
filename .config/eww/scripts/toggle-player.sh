#!/bin/bash

if eww active-windows | grep -q "music_player"; then
    eww close spotify_control
else
    eww open spotify_control
fi
