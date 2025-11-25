#!/bin/bash

DIR="$HOME/Imagens/Capturas de tela"
mkdir -p "$DIR"

FILE="$DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

CLIPBOARD_TOOL="wl-copy"
COPIED=false

case "$1" in
    full) grim "$FILE" ;;
    area) grim -g "$(slurp)" "$FILE" ;;
esac

if command -v "$CLIPBOARD_TOOL" &> /dev/null; then

    # Lê o conteúdo binário do arquivo e o envia para o wl-copy

    cat "$FILE" | "$CLIPBOARD_TOOL" --type image/png

    COPIED=true
    fi
