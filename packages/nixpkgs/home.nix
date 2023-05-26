{config, pkgs, callPackage, ... }:

{
	# Enables Flakes
	nix = {
		package = pkgs.nixVersions.stable;
		extraOptions = ''
		experimental-features = nix-command flakes
		'';
	};
	manual.json.enable = true;
	programs.home-manager.enable = true;
	nixpkgs.config.allowUnfree = true;	
	home.packages = with pkgs; [	
		# Games
		steam
		lutris
		heroic

		# Utilities
		libsForQt5.bismuth
		flameshot
		bitwarden
		swaylock
		swayidle
		swaybg
		light
		wofi
		rofi
		rofi-wayland
		dunst
		pipewire
		wireplumber
		jq
		playerctl
		grim
		slurp
		mpc-cli
		nerdfonts
		noto-fonts-emoji
		hyprland
		waybar
		eww-wayland
		xdg-desktop-portal-wlr
		catppuccin-gtk

		# Applications
		vivaldi
		vivaldi-widevine
		alacritty
		vlc
		solaar
		stow
		librespot #spotify
		bottles
		libreoffice
		notion-app-enhanced
	
		# cli-utils
		neovim
		lazygit
		exa
		fd
		ripgrep
		fish
		starship
		htop
		git
		rustup
		python39Full
		python39Packages.pip
		go
		docker
		docker-compose
		pulsemixer
		macchina

		# Dev tools
		postman
		#github-desktop
	];

	# User configuration
	home.username = "sawyer";
	home.homeDirectory = "/home/sawyer/";
	home.stateVersion = "22.11";

	programs.git = {
  		enable = true;
  		userName = "LegitCamper";
  		userEmail = "SawyerBristol@gmail.com";
  		aliases = {
    			prettylog = "...";
  		};
  		extraConfig = {
    			core = {
      				editor = "nvim";
    			};
    			color = {
      				ui = true;
    			};
    			push = {
      				default = "simple";
    			};
    			pull = {
      				ff = "only";
    			};
    			init = {
      				defaultBranch = "main";
    			};
  		};
  		ignores = [
    			".DS_Store"
    			"*.pyc"
  		];
	};
}
