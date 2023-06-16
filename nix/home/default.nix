{ pkgs, config, ... }:
let
  pulseaudio = pkgs.pulseaudioFull;
in
{
  imports = [
    ./modules/lxqt-policykit-agent.nix
    ./modules/nushell.nix
  ];
  config = {
    home.packages = with pkgs; [
      nixfmt
      home-manager
      nixpkgs-review

      networkmanagerapplet
      lxappearance
      # flameshot
      pavucontrol
      swaylock
      swayidle
      swaybg
      wofi
      rofi
      dunst
      playerctl
      hyprland
      waybar
      grim
      slurp

      bitwarden
      xfce.thunar
      ala
      socat
      qemu
      libreoffice
      vlc
      gnome.pomodoro
      ffmpeg-full
      procs
      solaar
      nuclear

      steam
      lutris
      heroicgames
      postman

      nmap
      fd
      bitwarden-cli
      stow
      alacritty
      kitty
      exa
      fd
      ripgrep
      fish
      htop
      
      ansible-core
      ansible-language-server
      clang
      ninja
      git
      python
      python3
      go
      npm
      ninja
      gcc
      docker
      docker-compose
      neovim
      lazygit
      gitui
      jq
      fzf
      cmake
    ];

    fonts.fontconfig.enable = true;
    gtk = {
      enable = true;
      font = {
        name = "Noto Sans 10";
        package = pkgs.noto-fonts;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
      gtk2.extraConfig = ''
        gtk-error-bell = 0
      '';

      gtk3.extraConfig = { gtk-error-bell = 0; };
    };
    # programs.ssh = {
    #   enable = true;

    #   matchBlocks = {
    #     "github.com" = {
    #       user = "git";
    #       identityFile = "~/.ssh/github_ed25519";
    #     };
    #   };

    #   forwardAgent = false;
    #   serverAliveInterval = 180;
    # };
    programs.fzf.enable = true;
    programs.bat.enable = true;
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };

    services.gnome-keyring.enable = ttrue    services.gpg-agent.enable = true;
    services.keybase.enable = true;
    services.network-manager-applet.enable = true;
    services.blueberry.enable = true;
    services.mpris-proxy.enable = true;
    # services.flameshot.enable = true;
    services.espanso.enable = true;

    services.xsettingsd.enable = true;
    services.xsettingsd.settings = {
      "Net/ThemeName" = "Adwaita-dark";
      "Xft/Antialias" = true;
      "Xft/Hinting" = true;
      "Xft/RGBA" = "rgb";
    };

    services.lxqt-policykit-agent.enable = true;

    services.pasystray.enable = true;

    systemd.user.services.bitwarden = {
      Unit = {
        Description = "Bitwarden";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = { ExecStart = "${pkgs.bitwarden}/bin/bitwarden"; };
    };

    programs.hyprland.enable = true;


    xdg.enable = true;

    # home.pointerCursor = {
    #   x11.enable = true;
    #   name = "Vanilla-DMZ";
    #   package = pkgs.vanilla-dmz;
    #   size = 128;
    # };

    programs.jq.enable = true;
    programs.neovim.enable = true;
    programs.nix-index.enable = true;
    programs.autorandr.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      # Store .envrc files outside of project directories.
      # Source: https://github.com/nix-community/nix-direnv#storing-direnv-outside-the-project-directory
      stdlib = builtins.readFile ./direnvrc;
    };
    programs.htop.enable = true;

    home.stateVersion = "21.03";
  };
}

