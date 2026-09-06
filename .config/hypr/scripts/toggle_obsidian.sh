#!/usr/bin/env bash
# Win+N: puxa o lotion pro workspace atual, ou manda ele de volta pro workspace 5
# (substitui a lógica antiga de togglespecialworkspace, já que o lotion
# agora mora fixo no workspace 5 em vez de um scratchpad especial)

LOTION_CLASS="lotion"
HOME_WS=5

# Pega info da janela do lotion (se estiver aberta)
window_json=$(hyprctl clients -j | jq -r --arg cls "$LOTION_CLASS" \
    '.[] | select(.class == $cls)')

if [ -z "$window_json" ]; then
    # Lotion não está aberto: abre normalmente (a windowrule já manda pro workspace 5)
    lotion &
    exit 0
fi

address=$(echo "$window_json" | jq -r '.address')
lotion_ws=$(echo "$window_json" | jq -r '.workspace.id')
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$lotion_ws" -eq "$HOME_WS" ] && [ "$active_ws" -ne "$HOME_WS" ]; then
    # Lotion está no workspace 5, e eu não estou lá: puxa ele pra cá
    hyprctl dispatch movetoworkspacesilent "$active_ws,address:$address"
    hyprctl dispatch focuswindow "address:$address"
else
    # Lotion já está aqui (ou em outro lugar): manda de volta pro workspace 5
    hyprctl dispatch movetoworkspacesilent "$HOME_WS,address:$address"
fi
