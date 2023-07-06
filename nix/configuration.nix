# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }: {

  nixpkgs.config = { allowUnfree = true; };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    allowed-users = [ "sawyer" "@wheel" ];
    trusted-users = [ "sawyer" "@wheel" ];
    warn-dirty = false;
    accept-flake-config = true;
  };

  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  sound.enable = true;
  hardware = {
    pulseaudio.enable = false;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  # List services that you want to enable:
  services = {
    printing.enable = true;
    flatpak.enable = true;
    upower.enable = true;
    dbus.enable = true;

    # enable sound with pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true;
      libinput.enable = true;
      layout = "us";
      xkbVariant = "";
    };

    # configures login manager
    greetd = {
      enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sawyer = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "input" "disk" "wireshark" ];
  };

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
    docker
    docker-compose

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
    pulseaudio
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

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

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
    tmpfiles.rules =
      [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];
  };

  networking.firewall.enable = false;
  networking.enableIPv6 = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

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
  system.copySystemConfiguration = false;
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
