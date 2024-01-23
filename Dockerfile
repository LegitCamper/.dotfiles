# syntax=docker/dockerfile:1
FROM archlinux:latest

ARG PASS="password"
RUN useradd -m -s /bin/bash sawyer && echo "sawyer:$PASS" | chpasswd

COPY ./.ansible-auto.txt /home/sawyer/.ansible-auto.txt

RUN pacman-key --init && \
  pacman -Syu --noconfirm && \
  pacman -S ansible go --needed base-devel git --noconfirm && \
  git clone https://aur.archlinux.org/yay.git && \
  chmod 777 yay && cd yay && sudo -u sawyer makepkg -si && yay --version
	
RUN ansible-pull -U https://github.com/LegitCamper/.dotfiles.git

CMD ["fish"]
