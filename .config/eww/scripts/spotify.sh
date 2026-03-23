#!/bin/bash

# Configurações
CMD="$1"
PLAYER="spotify"
CACHE_DIR="/tmp/eww_spotify_cache"
mkdir -p "$CACHE_DIR"

# Arquivos de cache
CACHE_ART_URL="$CACHE_DIR/current_art_url"
CACHE_COLOR="$CACHE_DIR/current_color"
LOCK_FILE="$CACHE_DIR/processing.lock" # Trava para evitar processos duplicados

# Função pesada: Roda em background
update_color_background() {
    local art_url="$1"
    local temp_image="$CACHE_DIR/cover.png"
    
    # Cria arquivo de trava (se já existir, sai para não empilhar processos)
    if [ -f "$LOCK_FILE" ]; then return; fi
    touch "$LOCK_FILE"

    # Download com TIMEOUT (essencial para não travar se a net cair)
    curl -s --max-time 5 "$art_url" -o "$temp_image"

    if [ -f "$temp_image" ]; then
        # Extrai cor
        RAW_HEX=$(convert "$temp_image" -resize 1x1\! -modulate 100,100,100 -depth 8 -format '%[hex:p{0,0}]' info: 2>/dev/null | tr -d '\n')

        if [[ ${#RAW_HEX} -eq 6 ]]; then
            echo "#$RAW_HEX" > "$CACHE_COLOR"
            # Atualiza a URL salva apenas APÓS processar com sucesso
            echo "$art_url" > "$CACHE_ART_URL"
        fi
        rm -f "$temp_image"
    fi

    # Remove a trava
    rm -f "$LOCK_FILE"
}

get_accent_color() {
    local art_url="$1"
    local default_color="#3c3836"

    # Se não tiver URL, retorna padrão
    if [ -z "$art_url" ]; then
        echo "$default_color"
        return
    fi

    local saved_url=""
    [ -f "$CACHE_ART_URL" ] && saved_url=$(cat "$CACHE_ART_URL")

    # Lê a cor atual do cache (ou usa default se não existir)
    local current_color="$default_color"
    [ -f "$CACHE_COLOR" ] && current_color=$(cat "$CACHE_COLOR")

    # SE a música mudou, dispara a atualização em BACKGROUND
    if [ "$art_url" != "$saved_url" ]; then
        # O '& disown' joga o processo para segundo plano e solta o terminal
        # O script principal continua IMEDIATAMENTE retornando a cor antiga/padrao por enquanto
        (update_color_background "$art_url" &) >/dev/null 2>&1
    fi

    # Retorna a cor (seja a nova já processada, ou a antiga enquanto processa)
    echo "$current_color"
}

get_data() {
    # Adicionado timeout ao playerctl para não travar se o Spotify bugar
    STATUS=$(timeout 1s playerctl -p $PLAYER status 2>/dev/null)

    if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
        # Coleta metadados (rápido)
        METADATA=$(playerctl -p $PLAYER metadata --format '{{title}}|{{artist}}|{{mpris:artUrl}}|{{mpris:length}}')
        IFS='|' read -r TITLE ARTIST ART_URL LENGTH <<< "$METADATA"

        # Tratamento de Strings
        TITLE=$(echo "$TITLE" | sed 's/"/\\"/g')
        ARTIST=$(echo "$ARTIST" | sed 's/"/\\"/g')
        ART_URL=$(echo "$ART_URL" | sed 's/open.spotify.com/i.scdn.co/')

        # Cálculos de tempo
        POSITION=$(playerctl -p $PLAYER position 2>/dev/null | cut -d. -f1)
        # Fallback seguro para length
        [ -z "$LENGTH" ] && LENGTH=100000000
        LENGTH_SEC=$(($LENGTH / 1000000))
        [ "$LENGTH_SEC" -le 0 ] && LENGTH_SEC=1
        
        # Evita erro de divisão por zero
        PERCENT=0
        if [ "$LENGTH_SEC" -gt 0 ]; then
            PERCENT=$(($POSITION * 100 / $LENGTH_SEC))
        fi

        POS_FORMAT=$(date -d@$POSITION -u +%M:%S)
        LEN_FORMAT=$(date -d@$LENGTH_SEC -u +%M:%S)
        
        # Volume
        VOL_DEC=$(playerctl -p $PLAYER volume)
        VOL_PERC=$(awk -v v="$VOL_DEC" 'BEGIN {print int(v * 100)}')

        if [ "$STATUS" = "Playing" ]; then ICON="⏸"; else ICON="▶"; fi

        # Chama a função de cor (agora segura e instantânea)
        ACCENT_COLOR=$(get_accent_color "$ART_URL")

        # JSON Output
        echo "{\"status\": \"$STATUS\", \"title\": \"$TITLE\", \"artist\": \"$ARTIST\", \"art\": \"$ART_URL\", \"position\": \"$POSITION\", \"length\": \"$LENGTH_SEC\", \"percent\": $PERCENT, \"pos_str\": \"$POS_FORMAT\", \"len_str\": \"$LEN_FORMAT\", \"vol\": $VOL_PERC, \"icon\": \"$ICON\", \"accent_color\": \"$ACCENT_COLOR\"}"
    else
        echo "{\"status\": \"Stopped\", \"title\": \"Spotify Offline\", \"artist\": \"-\", \"art\": \"\", \"percent\": 0, \"pos_str\": \"00:00\", \"len_str\": \"00:00\", \"vol\": 0, \"icon\": \"ERROR\", \"accent_color\": \"#3c3836\"}"
    fi
}

set_vol() {
    NEW_VOL=$(awk -v v="$2" 'BEGIN {print v / 100}')
    playerctl -p $PLAYER volume $NEW_VOL
}

case "$CMD" in
    "get") get_data ;;
    "vol") set_vol "$@" ;;
esac