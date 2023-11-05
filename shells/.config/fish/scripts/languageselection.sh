#!/bin/bash

devshells=$(echo $(pwd))
selected=$(echo $devshells | tr " " "\n" |
	fzf -i --header-first \
		--header="Select your language layout above.")

echo $selected
