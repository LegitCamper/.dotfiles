{ pkgs, ... }: {

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

  networking.hostName = "nixos-laptop";

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        mesa
        # amdvlk # outdated?
        # vaapiIntel
        libvdpau-va-gl
        vaapiVdpau
        libvdpau-va-gl
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
      driSupport32Bit = true;
      driSupport = true;
    };
  };
  environment.variables.AMD_VULKAN_ICD = "RADV";

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
  };
}
