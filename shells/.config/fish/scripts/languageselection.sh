#!/bin/bash

zellij_paths=$(echo ~/.config/zellij/layouts/*)
selected=$(echo $zellij_paths | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your language layout above.")

echo $selected
