#!/usr/bin/fish

function projects -d "Searches for project folders"
    set LANGUAGE_SELECTION $(bash ~/.config/fish/scripts/languageselection.sh)
    set SEARCH_PATH $(bash ~/.config/fish/scripts/projectselection.sh)
    set RANDOM $(shuf -i 1-1000000 -n 1)

    cd $LANGUAGE_SELECTION && \
        nix develop -c fish -Pc "
            cd $SEARCH_PATH 
                zellij -s dev-env-$RANDOM -l ~/.config/zellij/layouts/development.kdl \
                options --on-force-close detach --simplified-ui false
        "
    
end
