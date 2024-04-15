#!/bin/bash

echo ~/projects/$(ls -a ~/projects | \
	awk '{print $NF}' | tr " " "\n" | \
	fzf -i --header-first \
	--header="Select your project above.")
