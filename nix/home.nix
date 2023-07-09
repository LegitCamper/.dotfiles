{ config, pkgs, ... }:

{
  home.username = "sawyer";
  home.homeDirectory = "/home/sawyer";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # apps
    bitwarden
    libsForQt5.dolphin
    libsForQt5.ark
    libsForQt5.kate
    libsForQt5.gwenview
    libsForQt5.kcalc
    emote
    socat
    qemu
    libreoffice
    vlc
    gnome.pomodoro
    ffmpeg-full
    procs
    solaar
    discord
    vivaldi
    vivaldi-ffmpeg-codecs
    nuclear
    obsidian

    # gaming
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
    upower
    htop
    tldr

    # dev
    ansible-language-server
    git
    neovim
    lazygit
    gitui
    lua-language-server
    luaformatter # lua formatter
    taplo # toml lsp
    jq
    fzf
    postman
    wireshark-qt

    # rust tools
    exa
    ripgrep
    helix
    zellij
    macchina
    starship
    zoxide
    wezterm
  ];

  # theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Compact-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = [ "rimless" ]; # "black"
        variant = "macchiato";
      };
    };
  };
  qt = {
    enable = true;
    style.package = pkgs.catppuccin-kvantum;
    style.name = "Catpuccin-Macchiato-Compact-Mauve-Dark";
    platformTheme = "gtk";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
