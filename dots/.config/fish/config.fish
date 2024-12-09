# Fish shell config

### ADDING TO THE PATH
# First line removes the path; second line sets it.  Without the first line,
# your path gets massive and fish becomes very slow.
set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/Applications $HOME/.cargo/bin $fish_user_paths

### EXPORT ###
set fish_greeting # Supresses fish's intro message
set TERM screen-256color # Sets the terminal type
set EDITOR helix
set VISUAL kate
set -x GIT_SSH /usr/bin/ssh

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
set fish_color_normal "#8bd5ca"
set fish_color_autosuggestion "#8aadf4"
set fish_color_command "#a6da95"
set fish_color_error "#ed8796"
set fish_color_param "#a6da95"

### ALIASES ###
alias vim="nvim"
alias nano="nano -l"
alias lz="lazygit"
alias lg="lazygit"
alias find="fd"
alias grep="rg"
alias ls="eza -al --color=always --group-directories-first"
alias cat="bat"
alias history="atuin"
alias diff="delta"
alias watch="hwatch"
alias ps="procs"
set HELIX_RUNTIME ~/.config/helix/runtime
alias hx="helix"

# Power settings
alias suspend="systemctl suspend"
alias hibernate="echo disk | sudo tee /sys/power/state" # Requires sufficient swap space

# confirm before overwriting something
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# adding flags
alias df="df -h" # human-readable sizes
alias free="free -m" # show sizes in MB

# toolbox alias
alias podman="flatpak-spawn --host podman"

## Inits 
atuin init fish | source
starship init fish | source

macchina
