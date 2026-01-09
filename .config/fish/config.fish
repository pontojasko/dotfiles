if status is-interactive
	neofetch
    # Commands to run in interactive sessions can go here
end

# Aliases e Abbrs
    abbr -a gst 'git status'
    abbr -a gp 'git push'
    abbr -a g 'git'
    abbr -a gm 'git commit -m'
    abbr -a st 'shutdown'
    abbr -a ai 'mods'
	
# Created by `pipx` on 2025-12-11 19:19:59
set PATH $PATH /home/jasko/.local/bin
set -g fish_greeting ""
starship init fish | source
zoxide init fish | source # (Opcional: o zoxide é um 'cd' inteligente que aprende seus caminhos)

set -gx GEMINI_API_KEY "AIzaSyCYeJzdCoLbWZwLWLP1-aCNOYI7KTmUD0s"

set -gx MODS_DEFAULT_MODEL "gemini-1.5-flash"
set -gx MODS_DEFAULT_API "google"

