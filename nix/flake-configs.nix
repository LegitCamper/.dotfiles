{ inputs, config, pkgs, system, nixpkgs, ... }:
let pkgs = nixpkgs.legacyPackages.${system};
in {
  inherit pkgs;
  # modules = {{
  # inputs.nix-gaming.packages.${pkgs.system}.proton-ge
  # # inputs.nix-gaming.packages.${pkgs.system}.wine-ge
  # # inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
  # }}
}
