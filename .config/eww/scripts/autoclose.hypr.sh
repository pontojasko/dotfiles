

# Define o caminho do socket do Hyprland
# Verifica se está usando a variável de assinatura nova ou antiga
HYPR_SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ ! -S "$HYPR_SOCK" ]; then
    echo "Erro: Socket do Hyprland não encontrado em $HYPR_SOCK"
    exit 1
fi

# Conecta no socket e fica ouvindo
# Sempre que aparecer "workspace>>", ele fecha a janela do spotify
socat -U - UNIX-CONNECT:"$HYPR_SOCK" | grep --line-buffered "workspace>>" | while read -r line; do
    eww close spotify_control
done
