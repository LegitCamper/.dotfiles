# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ...}: 

  {
  nixpkgs.config.allowUnfree = true;
  
  # programs.adb.enable = true;

  nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (builtins.parseDrvName pkg.name).name [ "steam" ]);

  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-studio"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Denver";

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages=[ pkgs.terminus_font ];
    font="${pkgs.terminus_font}/share/consolefonts/ter-i22b.psf.gz";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # videosDrivers = ["amd"]; #["nvidia"];
    displayManager.gdm = {
      enable = false;
      wayland = true;
    };
	  displayManager.lightdm = {
      enable = true;
    };
  };
  
  hardware = {
    opengl.enable = true;
    nvidia.modesetting.enable = false;
    pulseaudio.support32Bit = true;
  };
  
  # hyprland
  programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      nvidiaPatches = false;
  };

  services.xserver.displayManager = {
  };
  
 services.picom.enable = true;
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sawyer = {
     isNormalUser = true;
     extraGroups = [ "wheel" "kvm" "input" "disk" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bash
    fish
    moreutils # sponge...
    unzip
    git
    wget
    htop
    efibootmgr
    ansible
    usbutils # lsusb

    # Networking tools
    inetutils # hostname ping ifconfig...
    dnsutils # dig nslookup...
    bridge-utils # brctl
    iw
    wirelesstools # iwconfig

    # nix
    nixfmt
    home-manager
    nixpkgs-review

    # window manager
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

    # apps
    bitwarden
    xfce.thunar
    socat
    qemu
    libreoffice
    vlc
    gnome.pomodoro
    ffmpeg-full
    procs
    solaar
    nuclear

    #fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    source-han-sans
    (nerdfonts.override { fonts = [ "JetBrainsMono" "noto-fonts" ]; })
    
    # gaming
    steam
    lutris
    heroic

    # cli
    nmap
    fd
    bitwarden-cli
    stow
    alacritty
    kitty
    fd
    fish
    htop
    
    # dev
    ansible-language-server
    clang
    ninja
    git
    python311
    go
    nodejs_20
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
    postman

    # rust tools
    exa
    ripgrep
    helix
    zellij
    starship
  ];

  # Gaming
	programs.steam = {
	  enable = true;
	  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
	  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};

  # List services that you want to enable:
  virtualisation.libvirtd.enable = true; 
  # enable flatpak support
  services.flatpak.enable = true;
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security = {
    polkit.enable = true;
    acpid.enable = true;
    upower.enable = true;
    tlp.enable = true;
  }
  
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  }; 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.enableIPv6 = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;  
  system.autoUpgrade.allowReboot = true; 
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-23.05";
  systemd.additionalUpstreamSystemUnits = ["debug-shell.service"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
