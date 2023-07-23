#!/bin/bash

devshells=$(echo ~/projects/.dotfiles/nix/devshells/*)
selected=$(echo $devshells| tr " " "\n" |
	fzf -i --header-first \
		--header="Select your language layout above.")

echo $selected
