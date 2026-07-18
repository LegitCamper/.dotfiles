#!/bin/bash

if command -v helix &> /dev/null; then
    helix "$@"
elif command -v hx &> /dev/null; then
    hx "$@"
else
    echo "could not find helix"
fi
