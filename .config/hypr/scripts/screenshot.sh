#!/bin/bash

# --- Configurações ---
DIR="$HOME/Imagens/Capturas de tela"
mkdir -p "$DIR"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
FILE_PATH="$DIR/$FILENAME"

# --- Função de Notificação Interativa ---
notify_user() {
    local file="$1"
    
    # Verifica se o dunstify existe, senão usa notify-send básico (fallback)
    if command -v dunstify &> /dev/null; then
        # Envia notificação e espera ação. 
        # "default,Abrir" define que o clique normal (default) chama a ação "Abrir"
        ACTION=$(dunstify "screenshot salva" "clique para abrir" \
            -i "$file" \
            --action="default,Abrir" \
            -u low)
            
        # Se a ação retornada for "default", abre o arquivo
        if [ "$ACTION" == "default" ]; then
            xdg-open "$file"
        fi
    else
        # Fallback caso não tenha dunstify
        notify-send "Screenshot Salva" "Salvo em: $(basename "$file")" -i "$file"
    fi
}

# --- Lógica de Captura ---
case "$1" in
    full)
        grim - | tee "$FILE_PATH" | wl-copy
        # Roda em background (&) para não travar o terminal esperando o clique
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