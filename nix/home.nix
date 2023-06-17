{ config, pkgs, ... }:

{
  home.username = "sawyer";
  home.homeDirectory = "/home/sawyer";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # symlinks dotfiles - like stow
  home = {
    file."~/.config".source = ./links/dotfiles;
    file."~/".source = ./links/homefiles;
  };

  # decrypts files with ansible

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
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

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
