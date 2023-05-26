#!/bin/bash

languages=$(echo "golang c rust python yml" | tr " " "\n")
echo $languages
core_utils=$(echo "find xargs sed awk" | tr " " "\n")
selected=$(echo -e "$languages\n$core_utils" | fzf -i --header-first --header="Enter the language or tool.")

read -p "GIMMIE YOUR QUERY: " query

if echo "$languages" | grep -qs $selected; then
	curl cht.sh/$selected/$(echo "$query" | tr " " "+")
else
	curl cht.sh/$selected~$query
fi
