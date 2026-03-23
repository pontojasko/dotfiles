#!/usr/bin/env python3
import subprocess
import json
import sys
import os

# Mapeamento de Ícones (Nerd Fonts)
# Adicione mais apps conforme necessário
ICON_MAP = {
    "firefox": "",
    "chromium": "",
    "google-chrome": "",
    "spotify": "",
    "discord": "",
    "telegram-desktop": "",
    "obs": "",
    "vlc": "嗢",
    "mpv": "",
    "code": "",
    "kitty": "",
    "alacritty": "",
    "steam": "",
    "default": ""
}

def get_icon(app_name):
    """Retorna o ícone baseado no nome do app (case insensitive)"""
    if not app_name:
        return ICON_MAP["default"]
    
    clean_name = app_name.lower()
    
    for key, icon in ICON_MAP.items():
        if key in clean_name:
            return icon
    return ICON_MAP["default"]

def get_sink_inputs():
    """Executa pactl e processa o JSON"""
    try:
        # Pega a lista de inputs em formato JSON
        result = subprocess.run(
            ["pactl", "-f", "json", "list", "sink-inputs"],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return []

        data = json.loads(result.stdout)
        apps = []

        for item in data:
            # Extrai dados relevantes
            sink_id = item.get("index")
            props = item.get("properties", {})
            
            # Tenta pegar o nome legível, fallback para binary name
            name = props.get("application.name", "Unknown")
            if name == "Unknown":
                name = props.get("application.process.binary", "System Sound")

            # Volume parsing logic
            # pactl retorna volume complexo, pegamos a média ou front-left
            volume_obj = item.get("volume", {})
            # Geralmente queremos 'front-left' -> 'value_percent' "45%"
            # Ou podemos pegar o primeiro canal disponível
            raw_vol = "0%"
            for channel in volume_obj.values():
                if "value_percent" in channel:
                    raw_vol = channel["value_percent"]
                    break
            
            # Remove o '%' e converte para int
            try:
                vol_int = int(raw_vol.strip('%'))
            except ValueError:
                vol_int = 0

            apps.append({
                "id": sink_id,
                "name": name,
                "volume": vol_int,
                "icon": get_icon(name)
            })

        return apps

    except Exception as e:
        # Em caso de erro, retorna lista vazia para não quebrar o Eww
        # sys.stderr.write(f"Error: {e}\n")
        return []

def main():
    # 1. Print inicial
    print(json.dumps(get_sink_inputs()), flush=True)

    # 2. Monitorar mudanças com pactl subscribe
    # Isso evita polling (loop infinito com sleep) e economiza CPU
    proc = subprocess.Popen(
        ["pactl", "subscribe"],
        stdout=subprocess.PIPE,
        text=True
    )

    try:
        for line in proc.stdout:
            # Se houver evento de mudança no sink-input, atualiza
            if "sink-input" in line:
                print(json.dumps(get_sink_inputs()), flush=True)
    except KeyboardInterrupt:
        proc.terminate()

if __name__ == "__main__":
    main()