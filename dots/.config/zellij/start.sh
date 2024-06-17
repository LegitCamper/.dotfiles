#!/bin/usr/bash

while true; do
  cd ~/projects/$(eza -a ~/projects/ | fzf --margin 30% --header="Select project")
  zellij
done
