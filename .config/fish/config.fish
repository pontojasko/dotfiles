if status is-interactive
	neofetch
    # Commands to run in interactive sessions can go here
end

# Aliases e Abbrs
    abbr -a gst 'git status'
    abbr -a push 'git push'
    abbr -a gm --set-cursor 'git commit -m "%"'

    abbr -a st 'shutdown'

    abbr -a ai 'mods'

    abbr -a feat --set-cursor 'git commit -m "feat: %"'
	abbr -a fix --set-cursor 'git commit -m "fix: %"'
    abbr -a refactor --set-cursor 'git commit -m "refactor: %"'
    abbr -a ui --set-cursor 'git commit -m "ui: %"'   
    abbr -a style --set-cursor 'git commit -m "style: %"'
    abbr -a run 'npm run dev'

# Created by `pipx` on 2025-12-11 19:19:59
set PATH $PATH /home/jasko/.local/bin
set -g fish_greeting ""
starship init fish | source
zoxide init fish | source # (Opcional: o zoxide é um 'cd' inteligente que aprende seus caminhos)

set -gx GEMINI_API_KEY "AIzaSyCYeJzdCoLbWZwLWLP1-aCNOYI7KTmUD0s"

set -gx MODS_DEFAULT_MODEL "gemini-1.5-flash"
set -gx MODS_DEFAULT_API "google"
set -gx EDITOR nano set -gx VISUAL nano
