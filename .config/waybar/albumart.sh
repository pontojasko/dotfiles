#!/bin/bash
# Define o arquivo temporário onde a capa será salva
TEMP_FILE="/tmp/waybar-album-art.png"
# Define um arquivo para rastrear a última URL baixada (para evitar downloads repetidos)
LAST_URL_FILE="/tmp/.last_art_url"

# Pega a URL da capa APENAS do Spotify
ART_URL=$(playerctl -p spotify metadata --format '{{mpris:artUrl}}' 2>/dev/null)

if [[ "$ART_URL" == https://* ]]; then
    # Se for uma URL HTTPS (como Spotify):
    LAST_URL=$(cat "$LAST_URL_FILE" 2>/dev/null)
    # Se a URL for nova, ou se o arquivo temporário não existir, faça o download
    if [[ "$ART_URL" != "$LAST_URL" ]] || [[ ! -f "$TEMP_FILE" ]]; then
        # Baixa a imagem (silenciosamente e com timeout)
        curl -s "$ART_URL" -o "$TEMP_FILE" --max-time 5
        # Salva a URL atual
        echo "$ART_URL" > "$LAST_URL_FILE"
    fi
    # Imprime o caminho local para o Waybar
    echo "$TEMP_FILE"
elif [[ "$ART_URL" == file://* ]]; then
    # Se for um caminho local:
    # Remove o prefixo 'file://'
    echo "${ART_URL:7}"
else
    # Se não houver música tocando no Spotify:
    # Limpa o arquivo temporário (para que a capa desapareça)
    rm -f "$TEMP_FILE" "$LAST_URL_FILE" 2>/dev/null
    echo ""
fi
