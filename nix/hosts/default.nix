{ inputs, withSystem, ... }: {
  flake.nixosConfigurations = withSystem "x86_64-linux"
    ({ system, self', inputs', pkgs, ... }:
      let
        sharedModules = withSystem "x86_64-linux" ({ ... }: [
          ../configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sawyer = import ../home.nix;
          }
        ]);

        systemInputs = { _module.args = { inherit self' inputs'; }; };
        inherit (inputs.nixpkgs.lib) nixosSystem;
      in {
        nixos-desktop = nixosSystem {
          inherit system;

          modules = [
            ./nixos-desktop.nix
            inputs.hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = false;
              };
            }
            systemInputs
          ] ++ sharedModules;

        };

        nixos-laptop = nixosSystem {
          inherit system;

          modules = [
            ./nixos-laptop.nix
            inputs.hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = false;
              };
            }
            systemInputs
          ] ++ sharedModules;

        };

        # deploy-rs configurations
        #   deploy.nodes.nixos-desktop.profiles.system = {
        #     user = "root";
        #     path = deploy-rs.lib.x86_64-linux.activate.nixos
        #       self.nixosConfigurations.nixos-desktop;
        #     autoRollback = true;
        #     magicRollback = true;
        #   };

        #   # This is highly advised, and will prevent many possible mistakes
        #   checks = builtins.mapAttrs
        #     (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      });
}
