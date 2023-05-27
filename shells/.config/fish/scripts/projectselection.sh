#!/bin/bash

project_paths=$(echo ~/projects/* ~/.config)
selected=$(echo $project_paths | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your project above.")

echo $selected
