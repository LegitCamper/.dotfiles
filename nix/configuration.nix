# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {

  nixpkgs.config = { allowUnfree = true; };

  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  imports = [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 30;
    };
    efi.canTouchEfiVariables = true;
  };

  # Use the grub EFI boot loader.
  # boot.loader = {
  #   grub = {
  #     enable = true;
  #     configurationLimit = 30;
  #     backgroundColor = "#3F2847";
  #     useOSProber = true;
  #     theme = pkgs.nixos-grub2-theme;
  #   };
  # };

  networking.hostName = "nixos-desktop"; # Define your hostname.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware = {
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        amdvlk
        # vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      # extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
      driSupport32Bit = true;
      driSupport = true;
    };
  };

  # List services that you want to enable:
  services = {
    flatpak.enable = true;
    upower.enable = true;
    dbus.enable = true;

    # sets up gdm while bug gets resolved
    xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # configures login manager
    greetd = {
      enable = false; # right now there is a bug that makes this laggy :/
      settings = {
        default_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd Hyprland
        '';
      };
    };

  };
  # the rest of greetd settings
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  # audio
  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sawyer = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "disk" "wireshark" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
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
    nixfmt # nix formatter
    nil # nix lsp
    home-manager
    nixpkgs-review

    # window manager
    networkmanagerapplet
    lxappearance
    pavucontrol
    # swaylock # borked - cannot login
    swayidle
    swaybg
    rofi
    wofi
    dunst
    playerctl
    # hyprland # being managed as a flake
    waybar
    grim
    slurp
    wl-clipboard

    # build tools
    gcc
    docker
    docker-compose
    clang-tools_9
    openssl
    pkg-config
    ninja
    cmake
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    source-han-sans
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  xdg.portal = {
    enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security = { polkit.enable = true; };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
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

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimise storage
  # you can alse optimise the store manually via:
  #    nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-23.05";
  systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
