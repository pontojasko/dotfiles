#!/bin/bash

# Define um arquivo fixo na pasta temporária
FILE="/tmp/tmp.mp4"

# Verifica se o wf-recorder já está rodando
if pgrep -x "wf-recorder" > /dev/null; then
    # --- PARAR GRAVAÇÃO ---
    
    # Envia sinal para salvar e fechar o arquivo
    pkill -SIGINT wf-recorder 
    
    # Aguarda um momento para garantir que o arquivo fechou
    while pgrep -x "wf-recorder" > /dev/null; do sleep 0.1; done

    # Notifica
    notify-send -u low "gravação finalizada" "copiado para o clipboard!"

    # --- MÁGICA DO CLIPBOARD ---
    # Copia o ARQUIVO em si para a área de transferência.
    # Isso permite dar CTRL+V direto no Discord, Telegram ou GitHub.
    echo -n "file://$FILE" | wl-copy --type text/uri-list
    
else
    rm -f "$FILE"
    GEOMETRY=$(slurp)
    [ -z "$GEOMETRY" ] && exit 1

    # OTIMIZADO PARA AMD RX 580 (Polaris)
    # 1. -c h264_vaapi: Usa o encoder de hardware
    # 2. -p qp=20: Garante qualidade sem arquivos gigantes (quanto menor, mais qualidade)
    # 3. out_color_matrix=bt709: Corrige o aspecto opaco/lavado
wf-recorder -y -g "$GEOMETRY" -f "$FILE" \
  --pixel-format yuv420p \
  -p vf="colorspace=all=bt709:ien=bt709" \
  --audio="$(pactl get-default-sink).monitor" &
fi