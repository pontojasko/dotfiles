#!/bin/bash

# --- Proteção Contra Múltiplas Execuções (Lock) ---
LOCK_FILE="/tmp/hyprland_screenshot.lock"

# Se o arquivo de lock existe e o processo ainda está rodando, aborta.
if [ -f "$LOCK_FILE" ]; then
    # Opcional: Verifica se o processo travado ainda existe de verdade para evitar travamento eterno em caso de crash
    if ps -p $(cat "$LOCK_FILE") > /dev/null; then

        exit 1
    fi
fi

# Cria o lock com o ID do processo atual
echo $$ > "$LOCK_FILE"

# Garante que o lock seja removido quando o script terminar (seja por sucesso, erro ou cancelamento)
trap 'rm -f "$LOCK_FILE"' EXIT

# --- Configurações ---
DIR="$HOME/Imagens/Capturas de tela"
mkdir -p "$DIR"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
FILE_PATH="$DIR/$FILENAME"

# --- Função de Notificação Interativa ---
notify_user() {
    local file="$1"
    
    # Verifica se o dunstify existe
    if command -v dunstify &> /dev/null; then
        # Ação interativa
        ACTION=$(dunstify "screenshot salva" "clique para abrir" \
            -i "$file" \
            --action="default,Abrir" \
            -u low)
            
        if [ "$ACTION" == "default" ]; then
            xdg-open "$file"
        fi
    else
        # Fallback
        notify-send "Screenshot Salva" "Salvo em: $(basename "$file")" -i "$file"
    fi
}

# --- Lógica de Captura ---
case "$1" in
    full)
        grim - | tee "$FILE_PATH" | wl-copy
        # Roda a notificação em background para liberar o terminal/lock
        notify_user "$FILE_PATH" & 
        ;;
    area)
        # O slurp bloqueia o script aqui. Graças ao Lock, se você apertar o atalho de novo
        # enquanto ainda não selecionou a área, o segundo comando será ignorado.
        GEOM=$(slurp)
        
        # Se o usuário cancelar (ESC), removemos o lock (o trap cuida disso) e saímos
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