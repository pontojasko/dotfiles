# my boring gruv dots

i realized that making my own dotfiles is easier . so i made it

started as a lazy fork from [husamuel](https://github.com/husamuel/hyprland-configs) but at this point barely anything from the original remains. rebuilt most of it from scratch: the eww widgets, the waybar, the theme system and the scripts.

<p align="center">

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8440413b-ffc4-4ad4-977e-bd3535f508bd" />
<img width="600" height="1200" alt="image" src="https://github.com/user-attachments/assets/e1fe0ce8-c5b4-4926-b640-1cad51985b06" />

</p>

---

## installation

### 1. clone

```bash
git clone https://github.com/pontojasko/dotfiles.git
cd dotfiles
```

### 2. backup

```bash
cp -r ~/.config ~/.config.backup
```

### 3. copy

```bash
cp -r .config/* ~/.config/
cp -r .themes ~/.themes
cp -r .icons ~/.icons
cp -r .local ~/.local
```

### 4. dependencies (arch)

```bash
# core
sudo pacman -S --needed hyprland hyprpaper hypridle hyprlock waybar dunst rofi \
  grim slurp wl-clipboard cliphist wtype brightnessctl playerctl ddcutil \
  alacritty nemo fish starship zoxide fastfetch jq socat imagemagick tesseract wf-recorder

# aur (yay/paru)
yay -S eww spicetify-cli bibata-cursor-theme-bin \
  ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd otf-libre-baskerville
```

### 5. install gtk theme

```bash
cd ~/.themes/Gruvbox-GTK-Theme-master/themes
./install.sh -t green -c dark
```

### 6. shell

```bash
chsh -s $(which fish)
# edit ~/.config/fish/config.fish — remove or replace the GEMINI_API_KEY line
```

### 7. eww

```bash
# eww daemon should auto-start, but to test:
eww daemon &
eww open spotify_control  # test the spotify widget
eww close spotify_control
```

### 8. go

```bash
hyprland
```

---


## what's in here

### the core

- **hyprland** — wayland compositor. dwindle layout, minimal gaps (2px inner, 5px outer), 1px borders, no blur, subtle shadows. fast window/workspace animations. workspaces 1–3 are persistent.
- **waybar** — status bar sitting at the bottom. 20px tall, monospace font at 8px. shows workspaces, clock, cpu, ram, brightness (via ddcutil), volume, do-not-disturb toggle, and a dark/light theme switch button. also shows the current spotify album art and synced lyrics right in the bar (via `waybar-lyric`).
- **dunst** — notifications. gruvbox colors, square corners, bottom-right position. clicking a notification opens the associated action. progress bars for volume/brightness feedback.
- **rofi** — application launcher. combined mode (drun + run + window), fuzzy search via fzf, papirus-dark icons. also handles clipboard history and power menu.
- **hyprpaper** — wallpaper daemon. rotates through `~/.config/hypr/wallpapers/` every 2 minutes.
- **hypridle** — idle management. dpms off after 15 minutes, full lock after 20 minutes.
- **hyprlock** — lock screen. gruvbox themed. shows time (top right, serif italic at 72px) and date. also displays the current spotify track and artist on the bottom-left corner, updating in real time. hidden password dots, background blur.

### eww widgets (the fun part)

the eww (ElKowars wacky widgets) config is where most of the custom stuff lives. these are declared in yuck (lisp-like syntax) and styled with scss. eww itself is written in rust — it's fast, gpu-rendered, and talks directly to the wayland compositor.

**spotify player overlay:**
a full media controller that pops up as a centered overlay at the bottom of the screen. shows album art (300x300), track title, artist name, a seekable progress bar with time labels, play/pause/skip controls, and volume slider. the container border color dynamically changes to match the album art's dominant color — extracted via ImageMagick on each track change, with a caching layer to avoid re-downloading and re-processing covers that haven't changed.

clicking the album art or the track info jumps you to workspace 3 and focuses the spotify window.

the player uses a hyprland **submap** — when it's open, your keyboard enters a dedicated mode where `space` toggles play/pause and `escape` closes the widget. this prevents accidental window actions while interacting with the player.

there's also an **autoclose script** that listens on hyprland's socket2. whenever you switch workspaces, it automatically closes the spotify overlay so it's not floating around where you don't want it.

**per-app audio mixer:**
a volume mixer widget anchored to the bottom-right (next to the volume indicator in waybar). lists all active audio streams (spotify, brave, discord, etc.) with per-app nerd font icons, volume percentage, and individual sliders. uses `pactl list sink-inputs` to enumerate streams and `pactl subscribe` to listen for changes in real time — no polling. the list is scrollable and dynamically sized based on how many apps are playing audio.

**theme support:**
both widgets have full dark and light variants. `dark.scss` and `light.scss` are separate stylesheets that get swapped via symlink when you toggle the theme.

### global dark/light theme toggle

one button on waybar. one click. it swaps:

- **waybar** — symlinks `style.css` to either `styledark.css` or `stylelight.css`, then sends `SIGUSR2` to reload.
- **eww** — symlinks `eww.scss` to either `dark.scss` or `light.scss`, then reloads eww.
- **gtk** — switches between `Gruvbox-Green-Dark` and `Gruvbox-Green-Light` via `gsettings`.
- **vs code** — rewrites the `workbench.colorTheme` value in `settings.json` using `jq`. switches between `Gruvbox Dark Hard` and `Gruvbox Light Soft`.

all four happen atomically in a single script (`toggle-theme.sh`).

### waybar in detail

**left:** workspace indicators with active highlight.

**center:** spotify album art thumbnail (12px square, clickable — opens the eww player), synced lyrics from `waybar-lyric` (replaces the clock when music is playing), clock (HH:MM, click to toggle full date).

**right:** do-not-disturb toggle (pauses/unpauses dunst), theme toggle icon (☀/☾), cpu %, ram %, brightness % (scroll to adjust via ddcutil), volume % (click opens the eww mixer, right-click mutes, scroll adjusts).

### screenshots and screen recording

**screenshot** (`print` or `super+shift+s`):
interactive area selection via slurp + grim. saves to `~/Imagens/Capturas de tela/` with timestamp, copies to clipboard simultaneously. sends an interactive dunst notification — click it to open the file. uses a lockfile to prevent double-firing if you hit the key too fast.

**full screenshot** also available in the script (just not bound by default).

**ocr** (`super+shift+alt+s`):
select a region, grim captures it, tesseract extracts the text, copies it to clipboard. notifies on success or failure.

**screen recording** (`super+r`):
toggle-style — first press starts recording (area select via slurp, encodes with wf-recorder), second press stops. output goes to `/tmp/tmp.mp4` and the file URI is copied to clipboard as `text/uri-list` so you can ctrl+v it directly into discord, telegram, etc. uses hardware-friendly encoding settings.

### clipboard

`super+v` opens clipboard history via rofi + cliphist. stores both text and images (two separate watchers on `wl-paste`). selecting an entry copies it and auto-pastes via `wtype`.

### notion integration

notion (via lotion) runs in a persistent special workspace. `super+n` pulls it into the current workspace as a tiled window. `super+q` on the notion window doesn't kill it — it silently moves it back to the special workspace instead. it's always running, just hidden.

### terminal and shell

- **alacritty** — gruvbox colors, caskaydia cove nerd font mono at 14px, underline cursor, no decorations, 90% opacity, dynamic padding.
- **fish shell** — with starship prompt and zoxide for smart directory jumping. runs fastfetch on startup (custom config with a cat ascii art). git abbreviations built in: `gst` → `git status`, `push` → `git push`, `feat` → `git commit -m "feat: ..."`, etc.
- **fastfetch** — shows distro, kernel, packages, shell, terminal, window manager, and current media. uses a custom cat ascii art and a dot separator.

### fonts

- **ui:** noto sans (sans-serif), noto serif (serif)
- **terminal/bar:** caskaydia cove nerd font mono
- **eww widgets:** jetbrains mono
- **lock screen:** libre baskerville, lora (italic)
- **hinting:** enabled, slight, rgb subpixel, lcd filter, antialiased

### gtk and cursors

- **gtk theme:** gruvbox-green (dark/light variants from [fausto-korpsvart](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme)), ships with full hdpi and xhdpi variants
- **cursor:** bibata-modern-ice, 24px
- **kde color scheme:** gruvbox (for qt apps)
- **qt theming:** qt6ct

### spicetify

spotify is themed via spicetify with the marketplace custom app installed. css and color injection are enabled.

### window rules

- floating: pavucontrol, nm-connection-editor, picture-in-picture
- workspace assignments: spotify → 3, vscode → 4, jetbrains → 4, zapzap → 2, telegram → 5
- jetbrains floating dialogs are forced centered and stay focused
- xwayland video bridge is fully hidden (0 opacity, no animation, no focus, 1x1 max size)
- floating windows get 70% inactive opacity

### wayland environment

the config sets up all the necessary env vars for a proper wayland session — electron apps use native wayland via `ELECTRON_OZONE_PLATFORM_HINT`, qt apps via `QT_QPA_PLATFORM=wayland;xcb`, sdl2 via `SDL_VIDEODRIVER=wayland`, mozilla via `MOZ_ENABLE_WAYLAND=1`, java via `_JAVA_AWT_WM_NONREPARENTING=1`.

---

## keybindings

super is the main modifier.

### apps

| key | action |
|-----|--------|
| `super + return` | terminal (alacritty) |
| `super + t` | terminal (alternative) |
| `super + super_l` | rofi launcher |
| `super + b` | browser (brave) |
| `super + e` | file manager (nemo) |
| `super + shift + e` | code editor (vscode) |
| `super + ctrl + i` | intellij idea |
| `super + g` | gemini (pwa) |
| `super + n` | bring notion to current workspace |

### windows

| key | action |
|-----|--------|
| `super + q` | close window (notion goes to scratchpad instead) |
| `super + w` | close window (alt) |
| `super + f` | fullscreen |
| `super + c` | toggle floating |
| `alt + tab` | toggle floating |
| `super + x` | pseudo-tile |
| `super + d` | toggle split |
| `super + h/j/k/l` | focus left/down/up/right |
| `super + shift + h/j/k/l` | move window |
| `super + ctrl + h/j/k/l` | resize window |
| `super + mouse drag` | move / resize window |

### workspaces

| key | action |
|-----|--------|
| `super + 1-0` | switch to workspace 1-10 |
| `super + ctrl + 1-0` | move window to workspace |
| `super + scroll` | cycle workspaces |
| `super + ctrl + scroll` | move window and cycle |
| `ctrl + alt + arrows` | next/prev workspace |
| `super + s` | toggle scratchpad |
| `super + shift + m` | move to scratchpad |

### media and volume

| key | action |
|-----|--------|
| `super + f10/f11` | volume down/up |
| `xf86 audio keys` | volume, mute, play/pause, next, prev |
| `super + shift + =/- ` | brightness up/down |
| `xf86 brightness keys` | external monitor brightness (ddcutil) |

### screenshots

| key | action |
|-----|--------|
| `print` / `super + shift + s` | screenshot area |
| `super + shift + alt + s` | ocr selection |
| `super + r` | screen recording toggle |

### system

| key | action |
|-----|--------|
| `super + escape` | lock (hyprlock) |
| `super + m` | exit hyprland |
| `super + ctrl + w` | reload waybar |
| `super + v` | clipboard history |

---

## structure

```
.
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf         # main config — monitors, env, input, appearance,
│   │   │                         #   window rules, keybinds, autostart
│   │   ├── hyprlock.conf         # lock screen — gruvbox theme, spotify info
│   │   ├── hypridle.conf         # idle — dpms 15min, lock 20min
│   │   ├── hyprpaper.conf        # wallpaper rotation
│   │   ├── scripts/
│   │   │   ├── screenshot.sh     # area/full screenshot with lock + notification
│   │   │   ├── gravar_tela.sh    # screen recording toggle (wf-recorder)
│   │   │   ├── init_portals.sh   # xdg portal initialization
│   │   │   └── rofi-power        # power menu (shutdown/reboot/lock/suspend/logout)
│   │   ├── rofi/
│   │   │   ├── power.rasi        # power menu style
│   │   │   └── rofi-gruvbox.rasi # gruvbox rofi theme
│   │   └── wallpapers/           # bundled wallpapers (5 included)
│   │
│   ├── eww/
│   │   ├── eww.yuck              # widget declarations — spotify player + audio mixer
│   │   ├── eww.scss → dark.scss  # active theme (symlink)
│   │   ├── dark.scss             # dark gruvbox theme for widgets
│   │   ├── light.scss            # light gruvbox theme for widgets
│   │   └── scripts/
│   │       ├── spotify.sh        # spotify metadata + accent color extraction
│   │       ├── audio_streams.sh  # per-app audio stream listing (pactl)
│   │       ├── toggle-player.sh  # open/close spotify widget + submap toggle
│   │       ├── autoclose.hypr.sh # close spotify widget on workspace switch
│   │       ├── album-art.sh      # album art fetcher
│   │       └── audio.sh          # audio utilities
│   │
│   ├── waybar/
│   │   ├── config.jsonc          # modules config — workspaces, lyrics, clock,
│   │   │                         #   cpu, ram, brightness, volume, dnd, theme
│   │   ├── style.css → styledark.css  # active theme (symlink)
│   │   ├── styledark.css         # dark waybar theme
│   │   ├── stylelight.css        # light waybar theme
│   │   ├── toggle-theme.sh       # global theme toggle (waybar+eww+gtk+vscode)
│   │   └── albumart.sh           # spotify album art downloader for waybar
│   │
│   ├── alacritty/                # terminal — gruvbox, caskaydia, 90% opacity
│   ├── rofi/                     # launcher — combined mode, fzf, gruvbox
│   ├── dunst/                    # notifications — gruvbox, square, bottom-right
│   ├── fish/                     # shell — starship, zoxide, git abbrs, fastfetch
│   ├── fastfetch/                # system info — custom cat ascii, gruvbox colors
│   ├── spicetify/                # spotify theming — marketplace
│   ├── fontconfig/               # font rendering — hinting, antialiasing, families
│   ├── gtk-3.0/                  # gtk3 settings
│   ├── gtk-4.0/                  # gtk4 settings
│   ├── nvim/                     # neovim (empty, bring your own)
│   ├── nwg-look/                 # gtk theme selector settings
│   ├── qt5ct/                    # qt5 theme config
│   └── qt6ct/                    # qt6 theme config
│
├── .themes/                      # gruvbox gtk themes (13 variants)
├── .icons/                       # bibata-modern-ice cursor
└── .local/share/
    └── color-schemes/            # gruvbox kde color scheme
```

---

## troubleshooting

**hyprland won't start with nvidia:**
```bash
# add to hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

**waybar not showing:** run `waybar &` from a terminal to see errors.

**gtk theme not applying to gtk4 apps:**
```bash
cd ~/.themes/Gruvbox-GTK-Theme-master/themes
./install.sh -l  # links libadwaita
```

**fonts not rendering:** run `fc-cache -fv`

**eww widgets not opening:** make sure the eww daemon is running (`eww daemon`). check `eww logs` for errors.

**ddcutil not working:** your user needs to be in the `i2c` group. `sudo usermod -aG i2c $USER`, then logout/login.

---

## credits

- forked originally from [husamuel/hyprland-configs](https://github.com/husamuel/hyprland-configs)
- gruvbox gtk theme by [fausto-korpsvart](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme)
- gruvbox colorscheme by [morhetz](https://github.com/morhetz/gruvbox)
- eww by [elkowar](https://github.com/elkowar/eww)

---

## license

mit. use it, fork it, change it. keep it real.
