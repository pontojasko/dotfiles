#!/bin/bash

LOCK_FILE="/tmp/hyprland_screenshot.lock"

if [ -f "$LOCK_FILE" ]; then
    if ps -p $(cat "$LOCK_FILE") > /dev/null; then

        exit 1
    fi
fi

echo $$ > "$LOCK_FILE"

trap 'rm -f "$LOCK_FILE"' EXIT

DIR="$HOME/Imagens/Capturas de tela"
mkdir -p "$DIR"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
FILE_PATH="$DIR/$FILENAME"

notify_user() {
    local file="$1"
    
    if command -v dunstify &> /dev/null; then
        ACTION=$(dunstify "screenshot salva" "clique para abrir" \
            -i "$file" \
            --action="default,Abrir" \
            -u low)
            
        if [ "$ACTION" == "default" ]; then
            xdg-open "$file"
        fi
    else
        notify-send "Screenshot Salva" "Salvo em: $(basename "$file")" -i "$file"
    fi
}

case "$1" in
    full)
        grim - | tee "$FILE_PATH" | wl-copy
        notify_user "$FILE_PATH" & 
        ;;
    area)
        GEOM=$(slurp)
        
        if [ -z "$GEOM" ]; then
            exit 1
        fi
        
        grim -g "$GEOM" - | tee "$FILE_PATH" | wl-copy
        notify_user "$FILE_PATH" &
        ;;
    *)
        echo "Uso: $0 {full|area}"
        exit 1
        ;;
esac
