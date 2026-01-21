# my boring gruv hyprland dots

i realized that making my own dotfiles is easier.  so i made it. 

a lazy fork from [husamuel](https://github.com/husamuel/hyprland-configs)

![Screenshot](https://i.postimg.cc/BSqPMd70/screenshot-2025-11-25-16-46-45.png)

## what you get

- hyper-minimal waybar
- happy background
- productive keybindings and workspace setup
- gruvbox gtk theme included
- fonts: inter variable & caskaydiacove nerd font
- fish shell with starship prompt
- zoxide for smart directory navigation

---

## the stack

**core components:**
- hyprland (wayland compositor)
- waybar (status bar)
- dunst (notifications)
- wofi (application launcher)
- swww (wallpaper daemon)
- hypridle (idle management)

**utilities:**
- grim & slurp (screenshots)
- wl-clipboard (clipboard manager)
- cliphist (clipboard history)
- brightnessctl (brightness control)
- ddcutil (monitor control)
- playerctl (media control)

**applications:**
- alacritty (terminal)
- fish (shell)
- starship (prompt)
- dolphin (file manager)
- brave (browser)

---

## installation

### 1. clone this repository

```bash
git clone https://github.com/pontojasko/dotfiles.git
cd dotfiles
```

### 2. backup your current configs

```bash
# if you have existing configs, back them up first
cp -r ~/.config ~/. config.backup
```

### 3. copy configuration files

```bash
# copy all configs
cp -r . config/* ~/.config/

# copy themes and icons
cp -r . themes ~/.themes
cp -r . icons ~/.icons
cp -r . local ~/.local
```

### 4. install dependencies

**on arch linux:**

```bash
sudo pacman -S --needed hyprland hypridle waybar dunst wofi grim slurp \
  wl-clipboard cliphist brightnessctl playerctl alacritty dolphin brave \
  fish starship
```

**aur packages (use yay or paru):**

```bash
yay -S swww bibata-cursor-theme ttf-inter-variable ttf-cascadia-code-nerd
```

### 5. install gruvbox gtk theme

```bash
cd .themes/Gruvbox-GTK-Theme-master/themes
./install.sh -t default -c dark
```

### 6. set up fish shell

```bash
# make fish your default shell
chsh -s $(which fish)

# note: you'll need to remove or update the GEMINI_API_KEY in .config/fish/config.fish
```

### 7. start hyprland

```bash
hyprland
```

---

## keybindings

super (windows key) is the main modifier. everything revolves around it.

### basic applications

- `super + return` - terminal (alacritty)
- `super + t` - terminal alternative
- `super + super_l` - launcher menu (rofi)
- `super + b` - browser (brave)
- `super + e` - file manager (nemo)
- `super + g` - gemini ai
- `super + shift + e` - code editor (vscode)
- `super + ctrl + i` - intellij idea

### window control

**close and toggle:**
- `super + q` - close active window
- `super + w` - close window (alternative)
- `super + c` - toggle floating mode
- `alt + tab` - toggle floating mode
- `super + f` - fullscreen
- `super + x` - pseudo-tiling
- `super + d` - toggle split orientation

**move focus (vim style):**
- `super + h/j/k/l` - move focus left/down/up/right
- `super + arrows` - same thing but with arrow keys

**move windows:**
- `super + shift + h/j/k/l` - move window left/down/up/right
- `super + left mouse` - drag window
- `super + right mouse` - resize window

**resize windows:**
- `super + ctrl + h/j/k/l` - resize by direction
- `super + ctrl + arrows` - resize with arrow keys

### workspaces

**switch workspace:**
- `super + 1-9` - go to workspace 1-9
- `super + 0` - go to workspace 10
- `super + mouse scroll` - navigate between workspaces
- `ctrl + alt + arrows` - previous/next workspace

**move window to workspace:**
- `super + ctrl + 1-9` - move window to workspace
- `super + ctrl + scroll` - move and follow to next/previous workspace

**special workspace (scratchpad):**
- `super + s` - open/close special workspace "magic"
- `super + shift + m` - move window to special workspace
- `super + n` - open/focus notion (special workspace)

### screenshots and screen recording

- `print` - screenshot area (interactive selection)
- `super + shift + s` - screenshot area (alternative)
- `super + shift + alt + s` - ocr (extract text from selection)
- `super + r` - record screen (start/stop recording)

### clipboard and utilities

- `super + v` - open clipboard history (rofi + cliphist)

### media and volume controls

**function keys:**
- `super + f10` - volume down
- `super + f11` - volume up

**hardware keys (if your keyboard has them):**
- `xf86audioraisevolume` - volume up
- `xf86audiolowervolume` - volume down
- `xf86audiomute` - mute/unmute
- `xf86audioplay` - play/pause
- `xf86audionext` - next track
- `xf86audioprev` - previous track

### brightness

**function keys:**
- `super + shift + =` - brightness up
- `super + shift + -` - brightness down

**hardware keys:**
- `xf86monbrightnessup` - brightness up (external monitor via ddcutil)
- `xf86monbrightnessdown` - brightness down (external monitor via ddcutil)

### system

- `super + escape` - lock screen (hyprlock)
- `super + m` - exit hyprland
- `super + ctrl + w` - reload waybar

### special mode: spotify menu

when spotify widget is open (submap):
- `space` - play/pause
- `escape` or `super + q` - close widget and return to normal

---

**note:** all keybindings with `binde` or `bindl` allow repetition when holding the key. those with `bind` execute only once.

---

## customization

### changing wallpaper

wallpapers are managed by swww. to change:

```bash
swww img /path/to/your/wallpaper.jpg
```

### modifying keybindings

edit `~/.config/hypr/hyprland.conf` and search for the `bind` sections.

### waybar customization

- config:  `~/.config/waybar/config`
- styling: `~/.config/waybar/style. css`

### gruvbox theme variants

the included gruvbox theme supports multiple variants:

```bash
cd ~/.themes/Gruvbox-GTK-Theme-master/themes
./install.sh --help  # see all options
./install.sh -t green -c dark  # green variant
./install. sh -t orange --tweaks outline  # orange with window outlines
```

---

## structure

```
.
├── . config/
│   ├── hypr/          # hyprland configuration
│   ├── waybar/        # waybar config and styling
│   ├── dunst/         # notification daemon
│   ├── wofi/          # application launcher
│   ├── alacritty/     # terminal emulator
│   ├── fish/          # fish shell config
│   └── ... 
├── .themes/           # gtk themes (gruvbox)
├── .icons/            # icon themes
└── .local/            # local data and fonts
```

---

## troubleshooting

### hyprland won't start

check if you have nvidia drivers.  you might need additional configuration:

```bash
# add to ~/.config/hypr/hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

### waybar not showing

make sure waybar is installed and check the logs:

```bash
waybar &  # run in foreground to see errors
```

### gtk theme not applying

for gtk4 apps, manually link the theme: 

```bash
cd ~/.themes/Gruvbox-GTK-Theme-master/themes
./install.sh -l  # link libadwaita
```

### fonts not showing

regenerate font cache: 

```bash
fc-cache -fv
```

---

## credits

- forked from [husamuel's hyprland configs](https://github.com/husamuel/hyprland-configs)
- gruvbox gtk theme by [fausto-korpsvart](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme)
- gruvbox colorscheme by [morhetz](https://github.com/morhetz/gruvbox)

---

## license

this project is licensed under the mit license - see the [license](license) file for details.

feel free to use, modify, and share. just keep it real.