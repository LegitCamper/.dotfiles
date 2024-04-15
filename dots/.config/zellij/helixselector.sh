#! /bin/bash

if $(which helix &> /dev/null); then
    helix
elif $(which hx &> /dev/null); then
    hx
else
    echo "could not find helix"
fi

