# syntax=docker/dockerfile:1
FROM ubuntu:latest AS build
RUN | 
  apt-get install ansible && 
  ansible-pull -U https://github.com/LegitCamper/.dotfiles.git
CMD ["fish"]
