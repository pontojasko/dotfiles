#!/bin/bash

title=$(playerctl -p spotify metadata title 2>/dev/null || echo "Nada tocando")
artist=$(playerctl -p spotify metadata artist 2>/dev/null || echo "Desconhecido")




echo "{\"title\": \"$title\", \"artist\": \"$artist\"}"
