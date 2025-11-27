#!/bin/bash

if eww active-windows | grep -q "music_player"; then
    eww close music_player
else
    eww open music_player
fi
