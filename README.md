# my borin gruv hyprland dots

<div style="background-color: #232136; border-left: 5px solid rgb(111, 142, 235); padding: 1em; margin-bottom: 1em; color: #e0def4;">
  <p>i realized that making my own dotfiles is easier . so i made it </p>
  
  <p>a lazy fork from <a href="https://github.com/husamuel/hyprland-configs">husamuel</a></p>
</div>

![Screenshot](https://i.postimg.cc/BSqPMd70/screenshot-2025-11-25-16-46-45.png)

## features

- hyper-minimal waybar  
- happy background  
- productive keybindings and workspace setup
- fonts: inter variable & caskaydiacove

---

## installation

1. **clone this repository**:

```bash
git clone https://github.com/pontojasko/dotfiles.git
cd dotfiles
```
2. **copy the configuration files to your home directory**:
```bash

cp -r .config/* ~/.config/

```
3. **install required programs:**

core: hyprland, waybar, dunst, wofi, swww, hypridle

tools: grim & slurp (screenshots), wl-clipboard, cliphist, brightnessctl, ddcutil, playerctl

apps: alacritty, dolphin, brave

```bash
sudo pacman -S --needed hyprland hypridle waybar dunst wofi grim slurp wl-clipboard cliphist brightnessctl playerctl alacritty dolphin brave 
# You might need AUR helpers (yay/paru) for: swww, bibata-cursor-theme

```

4. **start hyprland:**

```bash
hyprland
```

## how to use

here are the main shortcuts and commands from the hyprland configuration:

### terminal & applications
- `$mainmod + return` → open terminal (alacritty)  
- `$mainmod + d` → open application launcher (wofi)  
- `$mainmod + b` → open browser (vivaldi)  
- `$mainmod + o` → open obsidian  
- `$mainmod + m` → open email (thunderbird)  
- `$mainmod + e` → open file manager (thunar)  

### window management
- `$mainmod + h / l / k / j` → move focus (vim-style)  
- `$mainmod + shift + h / l / k / j` → move active window  
- `$mainmod + ctrl + h / l / k / j` → resize active window  

### workspace management
- `$mainmod + [1-0]` → switch workspace  
- `$mainmod + shift + [1-0]` → move window to workspace  
- `$mainmod + left / right` → switch workspace left/right  
- `$mainmod + mouse up / down` → scroll through workspaces  

### special workspaces
- `$mainmod + s` → toggle special workspace “magic”  
- `$mainmod + shift + s` → move window to special workspace  

### floating & pseudo-tiling
- `$mainmod + v` → toggle floating  
- `$mainmod + p` → toggle pseudo-tiling  
- `$mainmod + j` → toggle split orientation  

### screenshots
- `print` → full screenshot  
- `shift + print` → area screenshot  
- `$mainmod + print` → window screenshot  

### media & brightness
- `$mainmod + f11 / f10` → volume up / down  
- `$mainmod + shift + = / -` → brightness up / down  

### lock screen
- `$mainmod + escape` → lock screen (swaylock with custom theme)  

---

## 📜 license

this project is licensed under the mit license - see the [license](license) file for details.
