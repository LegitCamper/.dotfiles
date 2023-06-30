# Fish shell config

### ADDING TO THE PATH
# First line removes the path; second line sets it.  Without the first line,
# your path gets massive and fish becomes very slow.
set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/Applications $HOME/.cargo/bin $fish_user_paths

### EXPORT ###
set fish_greeting # Supresses fish's intro message
set TERM screen-256color # Sets the terminal type
#set EDITOR "emacsclient -t -a ''"                 # $EDITOR use Emacs in terminal
#set VISUAL "emacsclient -c -a emacs"              # $VISUAL use Emacs in GUI mode
set EDITOR /usr/bin/helix
set VISUAL kate

# nix open ssl path
set OPENSSL_DIR $(which openssl)
set PKG_CONFIG_PATH $(which openssl)

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
set fish_color_normal "#8bd5ca"
set fish_color_autosuggestion '#8aadf4'
set fish_color_command "#a6da95"
set fish_color_error '#ed8796'
set fish_color_param "#a6da95"

### ALIASES ###
alias clear="clear && fish"

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# vim and emacs
alias vim='nvim'
alias em='/usr/bin/emacs -nw'
alias emacs="emacsclient -c -a 'emacs'"
alias doomsync="~/.emacs.d/bin/doom sync"
alias doomdoctor="~/.emacs.d/bin/doom doctor"
alias doomupgrade="~/.emacs.d/bin/doom upgrade"
alias doompurge="~/.emacs.d/bin/doom purge"

# Lazy git alias
alias lg='lazygit'

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first' # all files and dirs
alias ll='exa -l --color=always --group-directories-first' # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

# Changing find and grep applications
alias find="fd"
alias grep="rg"

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# adding flags
alias df='df -h' # human-readable sizes
alias free='free -m' # show sizes in MB
alias lynx='lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss -vikeys'
alias vifm='./.config/vifm/scripts/vifmrun'
alias ncmpcpp='ncmpcpp ncmpcpp_directory=$HOME/.config/ncmpcpp/'
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# nano settings
alias nano="nano -l"

# termbin
alias tb="nc termbin.com 9999"

# the terminal rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Helix rename
# alias hx='helix'
set HELIX_RUNTIME ~/.config/helix/runtime

# nix shell aliases
alias update="bash ~/projects/.dotfiles/nix/.update.sh"
alias rust='nix-shell -p openssl pkg-config clippy rustup cargo --run "fish -c dev"'

# Runs Project scitpt
alias dev="projects"

### SETTING THE STARSHIP PROMPT ###
starship init fish | source

# runs macchina
macchina
