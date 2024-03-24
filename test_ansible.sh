#!/usr/bin/env bash

if [[ "$1" == "usedvm" ]]; then
  vagrant up --provision
  vagrant halt
elif [[ "$1" == "newvm" ]]; then
  vagrant destroy -f
  vagrant up --provision
  vagrant halt
elif [[ "$1" == "local" ]]; then
  sudo ansible-playbook \
  --connection=local local.yml
else
  echo "need to pass parameter like 'newvm'/'used' or 'local'"
fi
