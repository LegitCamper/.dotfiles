#!/usr/bin/env bash

sudo ansible-playbook --connection=local --inventory 127.0.0.1 --limit 127.0.0.1 local.yml
