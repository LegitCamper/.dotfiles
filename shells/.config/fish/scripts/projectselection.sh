#!/bin/bash

selected=$(echo ~/projects/* | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your project above.")

echo $selected
