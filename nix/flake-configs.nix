{ inputs, ... }: {
  flake.lib = {
    createSystem = hostName:
      { hardwareConfig, config }:
      ({ pkgs, lib, ... }:
        let
          my-packages = [
            inputs.anyrun.packages.${pkgs.system}.anyrun
            inputs.anyrun.packages.${pkgs.system}.applications
            inputs.anyrun.packages.${pkgs.system}.dictionary
            inputs.anyrun.packages.${pkgs.system}.rink

            inputs.nix-gaming.packages.${pkgs.system}.proton-ge
            inputs.nix-gaming.packages.${pkgs.system}.wine-ge

            inputs.nix-gaming.modules.pipewireLowLatency
          ];
        in {
          nixpkgs.overlays = [ ];

          enviroment.systemPackages = [ ] ++ my-packages;
          home.packages = [ ] ++ my-packages;
        });
  };
}
