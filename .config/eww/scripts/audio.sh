#!/bin/bash

# Este script lida com a comunicação entre o Eww e o Playerctl (Spotify)
# E também gerencia o áudio Mono/Stereo do sistema

CMD="$1"
PLAYER="spotify"
CACHE_DIR="/tmp/eww_spotify_cache"
MODULE_NAME="sink_name=mono_audio" # Nome do módulo de áudio mono

mkdir -p "$CACHE_DIR"

# Arquivos de cache
CACHE_ART_URL="$CACHE_DIR/current_art_url"
CACHE_COLOR="$CACHE_DIR/current_color"

# --- FUNÇÕES AUXILIARES ---

# Função para checar se o Mono está ativo
get_mono_status() {
    if pactl list modules short | grep -q "$MODULE_NAME"; then
        echo "true"
    else
        echo "false"
    fi
}

# Função para alternar (Toggle) o Mono
toggle_mono() {
    IS_MONO=$(get_mono_status)
    
    if [ "$IS_MONO" == "true" ]; then
        # Se já for mono, descarrega o módulo (volta ao normal)
        pactl unload-module module-remap-sink
    else
        # Se for stereo, carrega o módulo mono e define como padrão
        DEFAULT_SINK=$(pactl get-default-sink)
        pactl load-module module-remap-sink master=$DEFAULT_SINK $MODULE_NAME channels=2 channel_map=mono,mono
        pactl set-default-sink mono_audio
    fi
}

get_accent_color() {
    local art_url="$1"
    local default_color="#3c3836"

    if [ -z "$art_url" ]; then
        echo "$default_color"
        return
    fi

    local saved_url=""
    [ -f "$CACHE_ART_URL" ] && saved_url=$(cat "$CACHE_ART_URL")

    if [ "$art_url" != "$saved_url" ]; then
        local temp_image="$CACHE_DIR/cover.png"
        echo "$art_url" > "$CACHE_ART_URL"
        curl -s "$art_url" -o "$temp_image"

        if [ -f "$temp_image" ]; then
            RAW_HEX=$(convert "$temp_image" -resize 1x1\! -modulate 100,100,100 -depth 8 -format '%[hex:p{0,0}]' info: 2>/dev/null | tr -d '\n')
            if [[ ${#RAW_HEX} -eq 6 ]]; then
                NEW_COLOR="#$RAW_HEX"
                echo "$NEW_COLOR" > "$CACHE_COLOR"
                echo "$NEW_COLOR"
            else
                echo "$default_color" > "$CACHE_COLOR"
                echo "$default_color"
            fi
            rm -f "$temp_image"
        else
            echo "$default_color"
        fi
    else
        if [ -f "$CACHE_COLOR" ]; then
            cat "$CACHE_COLOR"
        else
            echo "$default_color"
        fi
    fi
}

# --- FUNÇÃO PRINCIPAL DE DADOS ---

get_data() {
    # Pega status do mono para incluir no JSON
    MONO_STATUS=$(get_mono_status)

    STATUS=$(playerctl -p $PLAYER status 2>/dev/null)

    if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
        TITLE=$(playerctl -p $PLAYER metadata title | sed 's/"/\\"/g')
        ARTIST=$(playerctl -p $PLAYER metadata artist | sed 's/"/\\"/g')
        ART_URL=$(playerctl -p $PLAYER metadata mpris:artUrl | sed 's/open.spotify.com/i.scdn.co/')

        POSITION=$(playerctl -p $PLAYER position 2>/dev/null | cut -d. -f1)
        LENGTH=$(playerctl -p $PLAYER metadata mpris:length 2>/dev/null)
        [ -z "$LENGTH" ] && LENGTH=100
        LENGTH_SEC=$(($LENGTH / 1000000))
        [ "$LENGTH_SEC" -eq 0 ] && LENGTH_SEC=1

        PERCENT=$(($POSITION * 100 / $LENGTH_SEC))

        POS_FORMAT=$(date -d@$POSITION -u +%M:%S)
        LEN_FORMAT=$(date -d@$LENGTH_SEC -u +%M:%S)

        VOL_DEC=$(playerctl -p $PLAYER volume)
        VOL_PERC=$(awk -v v="$VOL_DEC" 'BEGIN {print int(v * 100)}')

        if [ "$STATUS" = "Playing" ]; then ICON="⏸"; else ICON="▶"; fi

        SHUFFLE_STATUS=$(playerctl -p $PLAYER shuffle)
        LOOP_STATUS=$(playerctl -p $PLAYER loop)

        ACCENT_COLOR=$(get_accent_color "$ART_URL")
        if [ -z "$ACCENT_COLOR" ]; then ACCENT_COLOR="#3c3836"; fi

        # Incluímos "mono": "$MONO_STATUS" no JSON
        echo "{\"status\": \"$STATUS\", \"title\": \"$TITLE\", \"artist\": \"$ARTIST\", \"art\": \"$ART_URL\", \"position\": \"$POSITION\", \"length\": \"$LENGTH_SEC\", \"percent\": $PERCENT, \"pos_str\": \"$POS_FORMAT\", \"len_str\": \"$LEN_FORMAT\", \"vol\": $VOL_PERC, \"icon\": \"$ICON\", \"shuffle\": \"$SHUFFLE_STATUS\", \"loop\": \"$LOOP_STATUS\", \"accent_color\": \"$ACCENT_COLOR\", \"mono\": \"$MONO_STATUS\"}"
    else
        # Mesmo offline, enviamos o status do mono
        echo "{\"status\": \"Stopped\", \"title\": \"Spotify Offline\", \"artist\": \"-\", \"art\": \"\", \"percent\": 0, \"pos_str\": \"00:00\", \"len_str\": \"00:00\", \"vol\": 0, \"icon\": \"ERROR\", \"accent_color\": \"#3c3836\", \"mono\": \"$MONO_STATUS\"}"
    fi
}

set_vol() {
    NEW_VOL=$(awk -v v="$2" 'BEGIN {print v / 100}')
    playerctl -p $PLAYER volume $NEW_VOL
}

case "$CMD" in
    "get") get_data ;;
    "vol") set_vol "$@" ;;
    "toggle_mono") toggle_mono ;; 
esac