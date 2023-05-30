# syntax=docker/dockerfile:1
FROM ubuntu:latest AS build
RUN | apt-get update && apt-get install -y locales && \
  rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8apt-get install ansible && \
  ansible-pull -U https://github.com/LegitCamper/.dotfiles.git
CMD ["fish"]
