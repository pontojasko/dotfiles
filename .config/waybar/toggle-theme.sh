#!/bin/sh

# 0. Instalação de Dependências (Recomendado)
# Este script precisa do 'jq' para manipular o arquivo JSON de settings do VS Code.
# Se estiver usando Debian/Ubuntu: sudo apt install jq
# Se estiver usando Arch/Manjaro: sudo pacman -S jq
# Se estiver usando Fedora: sudo dnf install jq
# Certifique-se de que 'jq' está instalado!

# 1. Definir os diretórios, arquivos de estilo e temas.
# ----------------------------------------------------

# --- WAYBAR ---
WAYBAR_STYLE_DIR="$HOME/.config/waybar"
WAYBAR_STYLE_LINK="$WAYBAR_STYLE_DIR/style.css"
WAYBAR_STYLE_DARK="$WAYBAR_STYLE_DIR/styledark.css"
WAYBAR_STYLE_LIGHT="$WAYBAR_STYLE_DIR/stylelight.css"

# --- EWW ---
EWW_STYLE_DIR="$HOME/.config/eww"
EWW_STYLE_LINK="$EWW_STYLE_DIR/eww.scss"
EWW_STYLE_DARK="$EWW_STYLE_DIR/dark.scss"
EWW_STYLE_LIGHT="$EWW_STYLE_DIR/light.scss"

# --- GTK ---
# Nomes exatos (case-sensitive) dos temas GTK.
NWG_THEME_DARK="Gruvbox-Green-Dark"
NWG_THEME_LIGHT="Gruvbox-Green-Light"

# --- VS CODE ---
# Localização padrão do arquivo de settings do VS Code
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
# Nomes exatos (case-sensitive) dos temas do VS Code
VSCODE_THEME_DARK="Gruvbox Dark Hard" # <-- Troque este nome pelo seu tema escuro
VSCODE_THEME_LIGHT="Gruvbox Light Soft" # <-- Troque este nome pelo seu tema claro

# ----------------------------------------------------
# --- Lógica de Troca de Tema ---
# ----------------------------------------------------

# Inicializa as variáveis
CURRENT_WAYBAR_TARGET=""
NEW_WAYBAR_THEME=""
NEW_EWW_THEME=""
NEW_NWG_THEME=""
NEW_VSCODE_THEME=""

# Verifica para onde o link simbólico da Waybar aponta (usado como referência primária).
CURRENT_WAYBAR_TARGET=$(readlink -f "$WAYBAR_STYLE_LINK")

# --- Determina o Próximo Tema ---
if [ "$CURRENT_WAYBAR_TARGET" = "$WAYBAR_STYLE_DARK" ]; then
    # Se o tema atual é DARK, troque para LIGHT
    NEW_WAYBAR_THEME="$WAYBAR_STYLE_LIGHT"
    NEW_EWW_THEME="$EWW_STYLE_LIGHT"
    NEW_NWG_THEME="$NWG_THEME_LIGHT"
    NEW_VSCODE_THEME="$VSCODE_THEME_LIGHT"
    echo "Trocando para tema claro (light)..."
elif [ "$CURRENT_WAYBAR_TARGET" = "$WAYBAR_STYLE_LIGHT" ]; then
    # Se o tema atual é LIGHT, troque para DARK
    NEW_WAYBAR_THEME="$WAYBAR_STYLE_DARK"
    NEW_EWW_THEME="$EWW_STYLE_DARK"
    NEW_NWG_THEME="$NWG_THEME_DARK"
    NEW_VSCODE_THEME="$VSCODE_THEME_DARK"
    echo "Trocando para tema escuro (dark)..."
else
    # Inicialização padrão (se Waybar não for um link esperado, força a troca para LIGHT)
    echo "Waybar style.css não é um link simbólico esperado. Inicializando tema escuro (dark) como padrão."
    rm -f "$WAYBAR_STYLE_LINK"
    ln -s "$WAYBAR_STYLE_DARK" "$WAYBAR_STYLE_LINK"
    NEW_WAYBAR_THEME="$WAYBAR_STYLE_LIGHT" # Troca de Waybar_DARK para Waybar_LIGHT
    NEW_EWW_THEME="$EWW_STYLE_LIGHT"
    NEW_NWG_THEME="$NWG_THEME_LIGHT"
    NEW_VSCODE_THEME="$VSCODE_THEME_LIGHT"
fi

# ----------------------------------------------------
# 3. Executar a Troca (Waybar, Eww, GTK e VS Code)
# ----------------------------------------------------
if [ -n "$NEW_WAYBAR_THEME" ]; then
    
    # --- Troca do Tema Waybar ---
    rm -f "$WAYBAR_STYLE_LINK"
    ln -s "$NEW_WAYBAR_THEME" "$WAYBAR_STYLE_LINK"
    echo "Waybar: Troca concluída para: $(basename "$NEW_WAYBAR_THEME")"
    
    # Reinício da Waybar para recarregar o estilo
    if killall -SIGUSR2 waybar; then
        echo "Waybar: Reiniciada com sucesso para aplicar o novo tema."
    else
        echo "Waybar: Erro ao reiniciar. Certifique-se de que a Waybar está rodando."
    fi

    # --- Troca do Tema Eww ---
    rm -f "$EWW_STYLE_LINK"
    ln -s "$NEW_EWW_THEME" "$EWW_STYLE_LINK"
    echo "Eww: Troca concluída para: $(basename "$NEW_EWW_THEME")"

    if eww reload; then
        echo "Eww: Reiniciado para aplicar o novo tema."
    else
        echo "Eww: Não estava rodando, não foi necessário reiniciar."
    fi

    # --- Troca do Tema GTK usando gsettings ---
    gsettings set org.gnome.desktop.interface gtk-theme "$NEW_NWG_THEME"
    
    if [ $? -eq 0 ]; then
        echo "GTK: Tema aplicado com gsettings: $NEW_NWG_THEME"
    else
        echo "GTK: Erro ao aplicar tema com gsettings."
    fi

    # --- Troca do Tema VS Code usando jq ---
    if [ -f "$VSCODE_SETTINGS" ]; then
        # Usa 'jq' para atualizar a chave "workbench.colorTheme"
        jq --arg theme "$NEW_VSCODE_THEME" \
           '. + {"workbench.colorTheme": $theme}' \
           "$VSCODE_SETTINGS" > "$VSCODE_SETTINGS.tmp" && \
        mv "$VSCODE_SETTINGS.tmp" "$VSCODE_SETTINGS"
        
        if [ $? -eq 0 ]; then
            echo "VS Code: Tema aplicado: $NEW_VSCODE_THEME"
            # O VS Code deve recarregar o tema automaticamente se estiver aberto.
        else
            echo "VS Code: Erro ao aplicar tema com jq. Verifique se 'jq' está instalado e o arquivo de settings é válido."
        fi
    else
        echo "VS Code: Arquivo de settings ($VSCODE_SETTINGS) não encontrado. Tema não alterado."
    fi
fi