# my boring gruv dots

i realized that making my own dotfiles is easier, so i made it.

started as a lazy fork from [husamuel](https://github.com/husamuel/hyprland-configs) but at this point barely anything from the original remains. i rebuilt most of it from scratch: the eww widgets, the waybar, the theme system and the scripts.

<p align="center">
  <img width="1920" height="1080" alt="desktop screenshot" src="https://github.com/user-attachments/assets/8440413b-ffc4-4ad4-977e-bd3535f508bd" />
  <br>
  <img width="600" alt="eww spotify widget" src="https://github.com/user-attachments/assets/e1fe0ce8-c5b4-4926-b640-1cad51985b06" />
</p>

---

## installation

### 1. clone the repo
```bash
git clone https://github.com/pontojasko/dotfiles.git
cd dotfiles
```

### 2. backup your current config (just in case)
```bash
cp -r ~/.config ~/.config.backup
```

### 3. copy the dotfiles into place
```bash
cp -r .config/* ~/.config/
cp -r .themes ~/.themes
cp -r .icons ~/.icons
cp -r .local ~/.local
```

### 4. install dependencies (arch / cachyos)

**core packages**
```bash
sudo pacman -s --needed hyprland hyprpaper hypridle hyprlock waybar dunst rofi \
  grim slurp wl-clipboard cliphist wtype brightnessctl playerctl ddcutil \
  alacritty nemo fish starship zoxide fastfetch jq socat imagemagick tesseract wf-recorder
```

**aur packages (yay / paru)**
```bash
yay -s eww spicetify-cli bibata-cursor-theme-bin \
  ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd otf-libre-baskerville
```

### 5. install the gtk theme
```bash
cd ~/.themes/gruvbox-gtk-theme-master/themes
./install.sh -t green -c dark
```

### 6. set fish as your default shell
```bash
chsh -s $(which fish)
```

### 7. test eww
```bash
# eww daemon should start automatically via hyprland’s autostart, but you can test it manually:
eww daemon &
eww open spotify_control   # open the spotify widget
eww close spotify_control  # close it again
```

### 8. launch hyprland
```bash
hyprland
```

---

## what’s inside

### the core

- **hyprland** – wayland compositor. uses the dwindle layout, minimal gaps (2 px inner, 5 px outer), 1 px borders, no blur, subtle shadows. fast window/workspace animations. workspaces 1‑3 are persistent.
- **waybar** – bottom status bar (20 px tall, monospace font at 8 px). shows workspaces, clock, cpu, ram, brightness (via ddcutil), volume, dnd toggle, and a dark/light theme switch button. also displays the current spotify album art and synced lyrics (via `waybar-lyric`).
- **dunst** – notification daemon. gruvbox colors, square corners, bottom‑right position. clicking a notification opens the associated action. includes volume/brightness progress‑bar feedback.
- **rofi** – application launcher (combined drun + run + window). fuzzy search via fzf, papirus‑dark icons. also handles clipboard history and the power menu.
- **hyprpaper** – wallpaper daemon. rotates through `~/.config/hypr/wallpapers/` every 2 minutes.
- **hypridle** – idle management: dpms off after 15 min, full lock after 20 min.
- **hyprlock** – lock screen. gruvbox‑themed, shows time (top‑right, serif italic 72 px) and date, plus the current spotify track/artist (bottom‑left, updates in real time). hidden password dots, background blur.

### eww widgets (the fun part)

the eww (elkowars wacky widgets) config lives in `~/.config/eww/eww.yuck` (yuck/lisp‑like syntax) and is styled with scss. eww itself is written in rust – fast, gpu‑rendered, and talks directly to the wayland compositor.

**spotify player overlay**
- full‑screen‑centered media controller that appears as a bottom overlay.
- shows album art (300 × 300 px), track title, artist name, a seekable progress bar with time labels, play/pause/skip controls, and a volume slider.
- the container’s border color dynamically matches the album art’s dominant color (extracted via imagemagick on each track change, cached to avoid re‑downloads/re‑processing).
- clicking the album art or the track info jumps you to workspace 3 and focuses the spotify window.
- uses a hyprland **submap** – when the widget is open, the keyboard enters a dedicated mode where `space` toggles play/pause and `escape` closes the widget, preventing accidental window actions while interacting with the player.
- an **autoclose script** listens on hyprland’s socket 2; whenever you switch workspaces it automatically closes the spotify overlay so it doesn’t float around unwanted.

**per‑app audio mixer**
- volume‑mixer widget anchored to the bottom‑right (next to the volume indicator in waybar).
- lists all active audio streams (spotify, brave, discord, etc.) with nerd‑font icons, volume percentage, and individual sliders.
- uses `pactl list sink‑inputs` to enumerate streams and `pactl subscribe` to listen for changes in real time – no polling.
- the list is scrollable and dynamically sized based on how many apps are playing audio.

**theme support**
- both widgets have dark and light variants (`dark.scss` and `light.scss`). the active theme is swapped via a symlink when you toggle the theme.

### global dark/light theme toggle

one button on waybar. one click. it swaps:

- **waybar** – symlinks `style.css` → `styledark.css` or `stylelight.css`, then sends `sigusr2` to waybar to reload.
- **eww** – symlinks `eww.scss` → `dark.scss` or `light.scss`, then reloads eww.
- **gtk** – switches between `gruvbox‑green‑dark` and `gruvbox‑green‑light` via `gsettings`.
- **vs code** – rewrites the `workbench.colortheme` value in `settings.json` using `jq`. switches between `gruvbox dark hard` and `gruvbox light soft`.

all four changes happen atomically in a single script (`toggle-theme.sh`).

### waybar in detail

- **left:** workspace indicators with active highlight.
- **center:** spotify album‑art thumbnail (12 px square, clickable – opens the eww player), synced lyrics from `waybar-lyric` (replaces the clock when music is playing), clock (hh:mm, click to toggle full date).
- **right:** dnd toggle (pauses/unpauses dunst), theme‑toggle icon (☀/☾), cpu %, ram %, brightness % (scroll to adjust via ddcutil), volume % (click opens the eww mixer, right‑click mutes, scroll adjusts).

### screenshots & screen recording

**screenshot** (`print` or `super+shift+s`)
- interactive area selection via `slurp` + `grim`. saves to `~/imagens/capturas de tela/` with a timestamp, copies to the clipboard simultaneously.
- sends an interactive dunst notification – click it to open the file.
- uses a lockfile to prevent double‑firing if the key is hit too fast.
- a full‑screen screenshot is also available in the script (just not bound by default).

**ocr** (`super+shift+alt+s`)
- select a region, `grim` captures it, `tesseract` extracts the text, copies it to the clipboard. notifies on success or failure.

**screen recording** (`super+r`)
- toggle‑style: first press starts recording (area select via `slurp`, encodes with `wf-recorder`), second press stops.
- output goes to `/tmp/tmp.mp4` and the file uri is copied to the clipboard as `text/uri-list` so you can `ctrl+v` it directly into discord, telegram, etc.
- uses hardware‑friendly encoding settings.

### clipboard

`super+v` opens clipboard history via rofi + `cliphist`. stores both text and images (two separate watchers on `wl‑paste`). selecting an entry copies it and auto‑pastes via `wtype`.

### notion integration

notion (via lotion) runs in a persistent special workspace.
- `super+n` pulls it into the current workspace as a tiled window.
- `super+q` on the notion window doesn’t kill it – it silently moves it back to the special workspace instead.
- it’s always running, just hidden.

### terminal & shell

- **alacritty** – gruvbox colors, caskaydia cove nerd font mono at 14 px, underline cursor, no decorations, 90 % opacity, dynamic padding.
- **fish shell** – with starship prompt and zoxide for smart directory jumping. runs `fastfetch` on startup (custom config with a cat ascii art). git abbreviations built in: `gst → git status`, `push → git push`, `feat → git commit -m "feat: ..."` etc.
- **fastfetch** – shows distro, kernel, packages, shell, terminal, window manager, and current media. uses a custom cat ascii art and a dot separator.

### fonts

- **ui:** noto sans (sans‑serif), noto serif (serif)
- **terminal/bar:** caskaydia cove nerd font mono
- **eww widgets:** jetbrains mono
- **lock screen:** libre baskerville, lora (italic)
- **hinting:** enabled, slight, rgb subpixel, lcd filter, antialiased

### gtk & cursors

- **gtk theme:** gruvbox‑green (dark/light variants from [fausto‑korpsvart](https://github.com/fausto‑korpsvart/gruvbox‑gtk‑theme)), ships with full hdpi/xhdpi variants.
- **cursor:** bibata‑modern‑ice, 24 px.
- **kde color scheme:** gruvbox (for qt apps).
- **qt theming:** `qt6ct`.

### spicetify

spotify is themed via spicetify with the marketplace custom app installed. css and color injection are enabled.

### window rules

- **floating:** `pavucontrol`, `nm-connection-editor`, `picture-in-picture`
- **workspace assignments:** spotify → 3, vs code → 4, jetbrains → 4, zapzap → 2, telegram → 5
- **jetbrains floating dialogs** are forced centered and stay focused.
- **xwayland video bridge** is fully hidden (0 opacity, no animation, no focus, 1 × 1 max size).
- **floating windows** get 70 % inactive opacity.

### wayland environment

the config sets all necessary environment variables for a proper wayland session:
- electron apps use native wayland via `electron_ozone_platform_hint`.
- qt apps via `qt_qpa_platform=wayland;xcb`.
- sdl2 via `sdl_videodriver=wayland`.
- mozilla via `moz_enable_wayland=1`.
- java via `_java_awt_wm_nonreparenting=1`.

---

## keybindings

`super` is the main modifier (usually the windows key).

### apps
| key | action |
|-----|--------|
| `super + return` | terminal (alacritty) |
| `super + t` | terminal (alternative) |
| `super + super_l` | rofi launcher |
| `super + b` | browser (brave) |
| `super + e` | file manager (nemo) |
| `super + shift + e` | code editor (vs code) |
| `super + ctrl + i` | intellij idea |
| `super + g` | gemini (pwa) |
| `super + n` | bring notion to current workspace |

### windows
| key | action |
|-----|--------|
| `super + q` | close window (notion goes to scratchpad instead) |
| `super + w` | close window (alternative) |
| `super + f` | fullscreen |
| `super + c` | toggle floating |
| `alt + tab` | toggle floating |
| `super + x` | pseudo‑tile |
| `super + d` | toggle split |
| `super + h/j/k/l` | focus left/down/up/right |
| `super + shift + h/j/k/l` | move window |
| `super + ctrl + h/j/k/l` | resize window |
| `super + mouse drag` | move / resize window |

### workspaces
| key | action |
|-----|--------|
| `super + 1‑0` | switch to workspace 1‑10 |
| `super + ctrl + 1‑0` | move window to workspace |
| `super + scroll` | cycle workspaces |
| `super + ctrl + scroll` | move window and cycle |
| `ctrl + alt + arrows` | next/previous workspace |
| `super + s` | toggle scratchpad |
| `super + shift + m` | move to scratchpad |

### media & volume
| key | action |
|-----|--------|
| `super + f10 / f11` | volume down / up |
| `xf86audio*` keys | volume, mute, play/pause, next, prev |
| `super + shift + = / -` | brightness up/down |
| `xf86monbrightness*` keys | external monitor brightness (ddcutil) |

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

## directory structure
```
.
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf         # main config – monitors, env, input, appearance,
│   │   │                         #   window rules, keybinds, autostart
│   │   ├── hyprlock.conf         # lock screen – gruvbox theme, spotify info
│   │   ├── hypridle.conf         # idle – dpms 15 min, lock 20 min
│   │   ├── hyprpaper.conf        # wallpaper rotation
│   │   ├── scripts/
│   │   │   ├── screenshot.sh     # area/full screenshot with lock + notification
│   │   │   ├── gravar_tela.sh    # screen recording toggle (wf‑recorder)
│   │   │   ├── init_portals.sh   # xdg portal initialization
│   │   │   └── rofi-power        # power menu (shutdown/reboot/lock/suspend/logout)
│   │   ├── rofi/
│   │   │   ├── power.rasi        # power‑menu style
│   │   │   └── rofi-gruvbox.rasi # gruvbox rofi theme
│   │   └── wallpapers/           # bundled wallpapers (5 included)
│   │
│   ├── eww/
│   │   ├── eww.yuck              # widget declarations – spotify player + audio mixer
│   │   ├── eww.scss → dark.scss  # active theme (symlink)
│   │   ├── dark.scss             # dark gruvbox theme for widgets
│   │   ├── light.scss            # light gruvbox theme for widgets
│   │   └── scripts/
│   │       ├── spotify.sh        # spotify metadata + accent‑color extraction
│   │       ├── audio_streams.sh  # per‑app audio‑stream listing (pactl)
│   │       ├── toggle-player.sh  # open/close spotify widget + submap toggle
│   │       ├── autoclose.hypr.sh # close spotify widget on workspace switch
│   │       ├── album-art.sh      # album‑art fetcher
│   │       └── audio.sh          # audio utilities
│   │
│   ├── waybar/
│   │   ├── config.jsonc          # modules config – workspaces, lyrics, clock,
│   │   │                         #   cpu, ram, brightness, volume, dnd, theme
│   │   ├── style.css → styledark.css   # active theme (symlink)
│   │   ├── styledark.css         # dark waybar theme
│   │   ├── stylelight.css        # light waybar theme
│   │   ├── toggle-theme.sh       # global theme toggle (waybar+eww+gtk+vs code)
│   │   └── albumart.sh           # spotify album‑art downloader for waybar
│   │
│   ├── alacritty/                # terminal – gruvbox, caskaydia, 90 % opacity
│   ├── rofi/                     # launcher – combined mode, fzf, gruvbox
│   ├── dunst/                    # notifications – gruvbox, square, bottom‑right
│   ├── fish/                     # shell – starship, zoxide, git abbreviations, fastfetch
│   ├── fastfetch/                # system info – custom cat ascii, gruvbox colors
│   ├── spicetify/                # spotify theming – marketplace
│   ├── fontconfig/               # font rendering – hinting, antialiasing, families
│   ├── gtk-3.0/                  # gtk 3 settings
│   ├── gtk-4.0/                  # gtk 4 settings
│   ├── nvim/                     # neovim (empty, bring your own)
│   ├── nwg-look/                 # gtk theme selector settings
│   ├── qt5ct/                    # qt5 theme config
│   └── qt6ct/                    # qt6 theme config
│
├── .themes/                      # gruvbox gtk themes (13 variants)
├── .icons/                       # bibata‑modern‑ice cursor
└── .local/share/
    └── color-schemes/            # gruvbox kde color scheme
```

---

## troubleshooting

**hyprland won’t start with nvidia?**
```bash
# add to hyprland.conf
env = libva_driver_name,nvidia
env = gbm_backend,nvidia-drm
env = __glx_vendor_library_name,nvidia
```

**waybar not showing?**  
run `waybar &` from a terminal to see any error messages.

**gtk theme not applying to gtk 4 apps?**
```bash
cd ~/.themes/gruvbox-gtk-theme-master/themes
./install.sh -l   # links libadwaita
```

**fonts rendering incorrectly?**  
```bash
fc-cache -fv
```

**eww widgets not opening?**  
make sure the eww daemon is running (`eww daemon`). check `eww logs` for errors.

**ddcutil not working?**  
your user needs to be in the `i2c` group:
```bash
sudo usermod -ag i2c $user
# then log out and back in.
```

---

## credits

- forked originally from [husamuel/hyprland-configs](https://github.com/husamuel/hyprland-configs)
- gruvbox gtk theme by [fausto-korpsvart](https://github.com/fausto-korpsvart/gruvbox-gtk-theme)
- gruvbox colorscheme by [morhetz](https://github.com/morhetz/gruvbox)
- eww by [elkowar](https://github.com/elkowar/eww)

---

## license

mit.
