{ config, lib, pkgs, modulesPath, ... }: {

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
  #     theme = pkgs.nixos-grub2-theme;
  #   };
  # };

  networking.hostName = "nixos-desktop";

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
    xpadneo.enable = true;
    bluetooth.enable = true;
  };
  environment.variables.AMD_VULKAN_ICD = "RADV";

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
  };

  # form hardwar-configuration.nix
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "amdgpu" ];
  boot.initrd.kernelModules = [ "kvm-amd" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  # environment.systemPackages = with pkgs; [ alsa-firmware] ;
  boot.loader.grub.device = "/dev/disk/by-uuid/28DD-F3C8";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/409b1d4d-ccf5-43f2-a818-c3ee5391d854";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/28DD-F3C8";
    fsType = "vfat";
  };

  fileSystems."/mnt/games" = {
    device = "/dev/nvme2n1p1";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/d35004aa-c924-4599-9a4e-a0b5d33cfcc8"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
