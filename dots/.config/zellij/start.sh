#!/usr/bin/bash

while true; do
  project=$(eza -aD ~/projects/ | awk 'FNR==1  {print "New Project"}1' | \
    fzf --margin 30% --header="Select project")

  if [ "$project" = "New Project" ]; then
    clear && cd ~/projects && fish
  else
    cd ~/projects/$project
    zellij -s "$project"
  fi
done
