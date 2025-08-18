#!/usr/bin/bash

while true; do
  project=$(eza -aD ~/projects/ | fzf --margin 30% --header="Select project")
  cd ~/projects/$project
  zellij a $project || zellij -s "$project"
done
