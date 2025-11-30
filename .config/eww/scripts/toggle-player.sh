#!/bin/bash

if eww active-windows | grep -q "spotify_control"; then
    # SE ESTIVER ABERTA: Fecha e libera o teclado (reset)
    eww close spotify_control
    hyprctl dispatch submap reset
else
    # SE ESTIVER FECHADA: Abre e trava o teclado no modo (submap)
    eww open spotify_control
    hyprctl dispatch submap spotify_menu
fi
