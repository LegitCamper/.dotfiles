#!/usr/bin/fish

function dev -d "Searches for project folders"
    set SEARCH_PATH $(bash ~/.config/fish/scripts/projectselection.sh)
    set LANGUAGE_SELECTION $(bash ~/.config/fish/scripts/languageselection.sh $SEARCH_PATH)
    set RANDOM $(shuf -i 1-1000000 -n 1)

    cd $SEARCH_PATH 
    eval "$LANGUAGE_SELECTION -c \
        zellij -s dev-env-$RANDOM -l ~/.config/zellij/layouts/development.kdl \
        options --on-force-close detach --simplified-ui false"
    cd -
end
