#!/bin/bash

# Script para listar streams de áudio ativos no PulseAudio/PipeWire
# Retorna JSON formatado para uso com Eww

get_icon() {
    local app_name="$1"
    
    case "${app_name,,}" in
        *spotify*) echo "󰓇" ;;
        *firefox*|*chrome*|*chromium*|*brave*|*edge*) echo "󰈹" ;;
        *discord*) echo "󰙯" ;;
        *telegram*) echo "" ;;
        *vlc*) echo "󰕼" ;;
        *mpv*) echo "" ;;
        *music*|*rhythmbox*|*clementine*) echo "" ;;
        *steam*) echo "󰓓" ;;
        *game*) echo "󰊴" ;;
        *obs*) echo "󰐌" ;;
        *zoom*|*teams*|*meet*) echo "󰍫" ;;
        *alsa*|*pulseaudio*|*pipewire*) echo "󰕾" ;;
        *) echo "󰝚" ;;
    esac
}

get_streams() {
    local json_array="["
    local first=true
    local current_id=""
    local app_name=""
    local volume=""
    
    # Lê toda a saída do pactl
    while IFS= read -r line; do
        # Detecta início de um novo sink-input
        if [[ "$line" =~ ^Sink\ Input\ #([0-9]+) ]]; then
            # Se já tínhamos um ID anterior, processa
            if [[ -n "$current_id" ]] && [[ -n "$app_name" ]] && [[ -n "$volume" ]]; then
                icon=$(get_icon "$app_name")
                
                if [[ "$first" != true ]]; then
                    json_array+=","
                else
                    first=false
                fi
                
                json_array+="{\"id\":\"${current_id}\",\"name\":\"${app_name}\",\"volume\":${volume},\"icon\":\"${icon}\"}"
            fi
            
            # Reseta para o novo sink-input
            current_id="${BASH_REMATCH[1]}"
            app_name=""
            volume=""
            
        # Captura nome da aplicação
        elif [[ "$line" =~ application\.name\ =\ \"(.+)\" ]]; then
            [[ -z "$app_name" ]] && app_name="${BASH_REMATCH[1]}"
            
        # Fallback: nome do processo
        elif [[ "$line" =~ application\.process\.binary\ =\ \"(.+)\" ]]; then
            [[ -z "$app_name" ]] && app_name="${BASH_REMATCH[1]}"
            
        # Captura volume (primeira ocorrência)
        elif [[ -z "$volume" ]] && [[ "$line" =~ Volume:.*[[:space:]]([0-9]+)% ]]; then
            volume="${BASH_REMATCH[1]}"
        fi
        
    done < <(pactl list sink-inputs)
    
    # Processa o último sink-input se houver
    if [[ -n "$current_id" ]] && [[ -n "$app_name" ]] && [[ -n "$volume" ]]; then
        icon=$(get_icon "$app_name")
        
        if [[ "$first" != true ]]; then
            json_array+=","
        fi
        
        # Limpa o nome (remove path)
        app_name=$(basename "$app_name")
        
        json_array+="{\"id\":\"${current_id}\",\"name\":\"${app_name}\",\"volume\":${volume},\"icon\":\"${icon}\"}"
    fi
    
    json_array+="]"
    echo "$json_array"
}

# Modo listen - atualiza continuamente
listen_mode() {
    # Primeira saída imediata
    get_streams
    
    # Monitora mudanças no PulseAudio
    pactl subscribe 2>/dev/null | while read -r event; do
        # Atualiza quando houver mudanças em sink-inputs
        if [[ "$event" =~ (sink-input|change) ]]; then
            sleep 0.2  # Delay para garantir consistência
            get_streams
        fi
    done
}

# Modo padrão - uma saída só
default_mode() {
    get_streams
}

# Verifica argumento
case "${1:-}" in
    listen)
        listen_mode
        ;;
    *)
        default_mode
        ;;
esac