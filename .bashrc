if [[ $- != *i* ]]
then
    return
fi

# Locales
LANG="en_US.UTF-8"
LC_ALL="C.UTF-8"

export PATH=$HOME/.cargo/bin:$HOME/go/bin:$PATH

if [[ "$HOSTNAME" == "toolbx" ]]; then
    HELIX_RUNTIME="~/.config/helix/runtime"
    
    ### ALIASES ###
    alias lg="lazygit"
    alias ls="eza -al --color=always --group-directories-first"
    alias history="atuin"
    alias diff="delta"
    alias hx="helix"
    
    # adding flags
    alias df="df -h" # human-readable sizes
    alias free="free -m" # show sizes in MB
    
    eval -- "$(/usr/bin/starship init bash --print-full-init)"
fi
