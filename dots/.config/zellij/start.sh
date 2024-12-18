#!/bin/usr/bash

zellijname=$(shuf -i 1-100000 -n 1)

while true; do
  cd ~/projects/$(eza -a ~/projects/ | fzf --margin 30% --header="Select project")
  zellij -s $zellijname options --on-force-close quit
  zellij delete-session $zellijname

done
