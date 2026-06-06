if [[ $- != *i* ]]
then
    return
fi

export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"

if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
fi

if [[ "$HOSTNAME" == "toolbx" ]]
    then
        export PATH=$HOME/.cargo/bin:$HOME/go/bin:$PATH

        HELIX_RUNTIME="$HOME/.config/helix/runtime"
        HELIX_BIN="$HOME/.config/zellij/helixselector.sh"
        alias hx="$HELIX_BIN"
        alias helix="$HELIX_BIN"
        
        ### ALIASES ###
        alias lg="lazygit"
        alias ls="eza -la --color=always --group-directories-first"
        alias diff="delta"
        
        eval -- "$(/usr/bin/starship init bash --print-full-init)"

        clear
    else
        alias flatpak='flatpak --user'
        alias ls='ls --color=always'
        alias grep='grep --color=always'
        alias diff='diff --color=always'
fi

# Locales
LANG="en_US.UTF-8"
LC_ALL="C.UTF-8"

# adding flags
alias df="df -h" # human-readable sizes
alias free="free -m" # show sizes in MB
alias mkdir='mkdir -p'

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:ll:pwd:clear:history'
shopt -s histappend
PROMPT_COMMAND='history -a'

shopt -s checkwinsize
shopt -s autocd
shopt -s globstar
shopt -s cdspell
shopt -s dirspell

set completion-ignore-case on
set show-all-if-ambiguous on
set show-all-if-unmodified on
set mark-symlinked-directories on
set colored-stats on
set visible-stats on
set menu-complete-display-prefix on

eval "$(dircolors -b)"
