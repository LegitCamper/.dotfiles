~~Deploy with [Docker Dev Enviroment](https://open.docker.com/dashboard/dev-envs?url=https://github.com/LegitCamper/.dotfiles).~~

Depoy on ~~Ubuntu, Debian~~, Arch, ~~and OpenSuse~~:
`sudo ansible-pull -U https://github.com/LegitCamper/.dotfiles.git`

Deploy dots to Windows
```powershell
mkdir -p ~/projects/
cd ~/projects/
git clone https://github.com/LegitCamper/.dotfiles.git
cd .dotfiles

New-Item -Path $HOME\.config\komorebi -ItemType SymbolicLink -Value $HOME\projects\.dotfiles\windows_dots\komorebi\
New-Item -Path $HOME\.config\yasb -ItemType SymbolicLink -Value $HOME\projects\.dotfiles\windows_dots\yasb\
New-Item -Path $HOME\AppData\Roaming\alacritty -ItemType SymbolicLink -Value $HOME\projects\.dotfiles\windows_dots\alacritty\
New-Item -Path $HOME\AppData\Roaming\helix -ItemType SymbolicLink -Value $HOME\projects\.dotfiles\windows_dots\helix\
New-Item -Path $HOME\.config\starship.toml -ItemType SymbolicLink -Value $HOME\projects\.dotfiles\windows_dots\starship.toml
```
