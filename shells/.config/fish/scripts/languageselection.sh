#!/bin/bash

selected=$(echo rust python nix java go current_dir | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your language above.")

# https://nix-community.github.io/awesome-nix/#programming-languages

if [ $selected == rust ]; then
	echo nix develop github:cargo2nix/cargo2nix#bootstrap
elif [ $selected == go ]; then
	echo nix shell nixpkgs#go nixpkgs#libcap nixpkgs#gcc nixpkgs#gopls
elif [ $selected == python ]; then
	echo nix shell nixpkgs#python39
# elif [ $selected == lang ]; then
elif [ $selected == current_dir ]; then
	echo nix develop $1
else
	echo nix develop $1
fi

	
