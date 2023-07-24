{
  description = "Sawyer's NixOS Flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://helix.cachix.org"
      "https://fufexan.cachix.org"
      "https://hyprland.cachix.org"
      "https://cache.privatevoid.net"
      "https://anyrun.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil/2023-05-09";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    fu.url = "github:numtide/flake-utils";

    helix = {
      url = "github:SoraTenshi/helix/new-daily-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, deploy-rs, hyprland
    , anyrun, ... }:
    let
    in {
      nixosConfigurations = {
        # Configuration for Gaming Desktop
        nixos-desktop = nixpkgs-unstable.lib.nixosSystem {
          system.packages =
            [ anyrun.packages.${nixpkgs-unstable}.anyrun-with-all-plugins ];

          modules = [
            ./configuration.nix # system configuration
            ./hosts/nixos-desktop.nix # system specific configuration

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sawyer = import ./home.nix;
            }

            # Hyprland flake configuration
            hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = false;
              };
            }
          ];
        };

        # Configuration for HP laptop
        nixos-laptop = nixpkgs-unstable.lib.nixosSystem {
          system.packages =
            [ anyrun.packages.${nixpkgs-unstable}.anyrun-with-all-plugins ];

          modules = [
            ./configuration.nix # system configuration
            ./hosts/nixos-laptop.nix # system specific configuration

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sawyer = import ./home.nix;
            }

            # Hyprland flake configuration
            hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = false;
              };
            }
          ];
        };

        # Configuration for Dell laptop
        nixos-dell-laptop = nixpkgs-unstable.lib.nixosSystem {
          system.packages =
            [ anyrun.packages.${nixpkgs-unstable}.anyrun-with-all-plugins ];

          modules = [
            ./configuration.nix # system configuration
            ./hosts/nixos-dell-laptop.nix # system specific configuration

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sawyer = import ./home.nix;
            }

            # Hyprland flake configuration
            hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = true;
                # hidpi = true;
              };
            }
          ];
        };
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
    };
}
