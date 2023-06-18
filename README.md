Deploy with [Docker Dev Enviroment](https://open.docker.com/dashboard/dev-envs?url=https://github.com/LegitCamper/.dotfiles).

Depoy on Ubuntu, Debian, Arch, and OpenSuse:
`sudo ansible-pull -U https://github.com/LegitCamper/.dotfiles.git`

deploy on NixOs:
`nix-env --install ansible-core git` then
`sudo ansible-pull -U https://github.com/LegitCamper/.dotfiles.git nix/local.yml`
