{
  description = "Sawyer's NixOS Flake";

  ##################################################################################################################
  # 
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out [NixOS & Nix Flakes - A Guide for Beginners](https://thiscute.world/en/posts/nixos-and-flake-basics/)!
  # 
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [ "https://cache.nixos.org" "https://hyprland.cachix.org" ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's stable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # rust-overlay.url = "github:oxalica/rust-overlay";
    hyprland.url = "github:hyprwm/Hyprland";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # community wayland nixpkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # hyprland flake
    # nixpkgs-hyprland.url = "github:hyprwm/Hyprland";

    # nix language server, used by vscode & neovim
    nil.url = "github:oxalica/nil/2023-05-09";
  };

  # `outputs` are all the build result of the flake.
  # A flake can have many use cases and different types of outputs.
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, This special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, ... }@inputs: {
      nixosConfigurations = {
        # By default, NixOS will try to refer the nixosConfiguration with its hostname.
        # so the system named `nixos-test` will use this configuration.
        # However, the configuration name can also be specified using `sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>`.
        # The `nixpkgs.lib.nixosSystem` function is used to build this configuration, the following attribute set is its parameter.
        # Run `sudo nixos-rebuild switch --flake .#nixos-test` in the flake's directory to deploy this configuration on any NixOS system
        nixos-desktop = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.sawyer = import ./home.nix;
            }

            # Hyprland flake installation
            hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                nvidiaPatches = false;
                # xwayland = {
                # enable = true;
                # hidpi = false;
                # };
              };
            }
          ];
        };
      };
    };
}
