if [[ $- != *i* ]]
then
    return
fi

# Locales
LANG="en_US.UTF-8"
LC_ALL="C.UTF-8"

export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"

if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
fi

if [[ "$HOSTNAME" == "toolbx" ]]
    then
        export PATH=$HOME/.cargo/bin:$HOME/go/bin:$PATH

        HELIX_RUNTIME="~/.config/helix/runtime"
        alias hx="$HELIX_RUNTIME"
        alias helix="$HELIX_RUNTIME"
        
        ### ALIASES ###
        alias lg="lazygit"
        alias ls="eza -la --color=always --group-directories-first"
        alias diff="delta"
        
        eval -- "$(/usr/bin/starship init bash --print-full-init)"

        clear
    else
        alias ls='ls --color=always'
        alias grep='grep --color=always'
        alias diff='diff --color=always'
        
        # adding flags
        alias df="df -h" # human-readable sizes
        alias free="free -m" # show sizes in MB
fi
