#!/usr/bin/fish

function projects -d "Searches for project folders"
    set LANGUAGE_SELECTION $(bash ~/.config/fish/scripts/languageselection.sh)
    set SEARCH_PATH $(bash ~/.config/fish/scripts/projectselection.sh)
    set RANDOM $(shuf -i 1-1000000 -n 1)

    cd $SEARCH_PATH
    # nix-shell --command "zellij -s develoment-enviroment-$RANDOM -l $LANGUAGE_SELECTION options --on-force-close detach --simplified-ui false"
    nix develop -c zellij -s develoment-enviroment-$RANDOM -l $LANGUAGE_SELECTION options --on-force-close detach --simplified-ui false
    
end
