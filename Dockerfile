# syntax=docker/dockerfile:1
FROM archlinux:latest

RUN run pacman-key --init && pacman -Syu ansible yay

ARG PASS="some password"
RUN useradd -m -s /bin/bash sawyer && echo "sawyer:$PASS" | chpasswd

COPY ./.ansible-auto.txt /home/sawyer/.ansible-auto.txt
	
RUN ansible-pull -U https://github.com/LegitCamper/.dotfiles.git

CMD ["fish"]
