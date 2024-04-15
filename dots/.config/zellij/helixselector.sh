#! /bin/bash

if $(which helix &> /dev/null); then
    helix
    exit
elif $(which hx &> /dev/null); then
    hx
    exit
else
    echo "could not find helix"
fi

