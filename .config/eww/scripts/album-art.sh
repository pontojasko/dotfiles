#!/bin/bash

# Tenta pegar a arte do álbum
art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)



if [ -n "$art_url" ]; then
    # Remove o 'file://' se existir
    art_path="${art_url#file://}"
    echo "$art_path"
else
    # Imagem padrão se não houver capa
    echo "$HOME/.config/eww/default-cover.png"
fi
