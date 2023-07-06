{ lib, config, pkgs, modulesPath, ... }: {

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

  # from hardware-configuration.nix
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/049138bd-02ad-4dce-856a-da4f1212c858";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5AB4-FB64";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
