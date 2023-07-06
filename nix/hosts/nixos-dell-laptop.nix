{ config, pkgs, lib, ... }: {

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

  networking.hostName = "nixos-dell-laptop";

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      driSupport = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "nvidia-x11" ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = true;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
