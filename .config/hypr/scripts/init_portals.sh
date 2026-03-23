#!/bin/bash
sleep 1
# Mata processos antigos para evitar conflitos
killall -9 xdg-desktop-portal-hyprland
killall -9 xdg-desktop-portal-kde
killall -9 xdg-desktop-portal-wlr
killall -9 xdg-desktop-portal

# Atualiza as variáveis de ambiente no DBus e Systemd
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Inicia o portal do Hyprland e o portal genérico
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
