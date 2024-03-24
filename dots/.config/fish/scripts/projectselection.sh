#!/bin/bash

selected=$(ls -a ~/projects | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your project above.")

echo $selected
