# syntax=docker/dockerfile:1
FROM ubuntu:latest AS build

RUN apt-get update && apt-get install -y locales && \
  rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt update && \
	apt install software-properties-common git -y  && \
	add-apt-repository --yes --update ppa:ansible/ansible && \
	apt install ansible -y	
	
RUN ansible-pull -U https://github.com/LegitCamper/.dotfiles.git

CMD ["fish"]
