{ config, lib, packages, pkgs, inputs', ... }: {
  environment.systemPackages = [
    # inputs'.anyrun.packages.anyrun
    # inputs'.anyrun.packages.applications
    # inputs'.anyrun.packages.dictionary
    # inputs'.anyrun.packages.rink

    # inputs'.ags.packages.default

    inputs'.nix-gaming.packages.proton-ge
    inputs'.nix-gaming.packages.wine-ge
    #inputs'.nix-gaming.modules.pipewireLowLatency
  ];

}
