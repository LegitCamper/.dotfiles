# updates nixos systems

cd ~/projects/.dotfiles/nix

git restore .

git pull

rm -rm flake.lock

sudo nixos-rebuild switch  
nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command  
sudo nixos-rebuild switch --impure --flake .#nixos-desktop

cd -