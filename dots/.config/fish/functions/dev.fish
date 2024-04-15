#!/usr/bin/fish

function dev -d "Searches for projects"
    set SEARCH_PATH $(bash ~/.config/fish/scripts/projectselection.sh)
    set RANDOM $(shuf -i 1-1000000 -n 1)

    cd $SEARCH_PATH && \ 
        zellij -s dev-env-$RANDOM -l ~/.config/zellij/layouts/development.kdl \
        options --on-force-close detach --simplified-ui false #" && \
        cd -
end
