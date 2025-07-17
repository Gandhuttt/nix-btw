# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (run ‘nixos-help’).

{ config, pkgs, ... }:

let 
  gandhuttt = import (builtins.fetchTarball {
    url = "https://github.com/Gandhuttt/nix-btw/archive/c215246a49b0c4300bc31e159ab353840dc134fc.tar.gz";
  }) { inherit pkgs; };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
  ];

  hardware.bluetooth.enable = true;

  # Bootloader and kernel
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    kernelParams = [ "usbcore.autosuspend=-1" ];
    kernelModules = [ "i2c-dev" "xpad" "hid-nintendo" "xone" "xpadneo" "fuse" ];
    extraModulePackages = [
      config.boot.kernelPackages.ddcci-driver
      config.boot.kernelPackages.xone
      config.boot.kernelPackages.xpadneo
      (config.boot.kernelPackages.callPackage gandhuttt.xpad {})
    ];
  };

  # Filesystems
  fileSystems."/windows" = {
    device = "/dev/disk/by-uuid/CEC43E24C43E0EE9";
    fsType = "ntfs";
  };


  # Udev rules
  services.udev.extraRules = ''
    ACTION=="add", \
    ATTRS{idVendor}=="2dc8", \
    ATTRS{idProduct}=="3106", \
    RUN+="${pkgs.kmod}/bin/modprobe xpad", \
    RUN+="${pkgs.bash}/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'"
  '';

  # Networking
  networking.networkmanager.enable = true;
  networking.hosts = {
    "192.168.1.23" = ["raspberrypi"];
    "127.0.0.1" = ["nixos"];
  };



  # Bluetooth
  services.blueman.enable = true;

  # Timezone and locale
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 + Display Manager (disabled LightDM explicitly)

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = false;
  };


  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    grim slurp wl-clipboard sway-contrib.grimshot mako
    efibootmgr ntfs3g git usbutils v4l-utils btop jmtpfs bluetui tio xorg.xhost
  ];

  # User setup
  users.users.gandhi = {
    isNormalUser = true;
    description = "Gandhi";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "dialout" "kvm" "podman" ];
    subGidRanges = [{
      count = 65536;
      startGid = 100000;
    }];
    subUidRanges = [{
      count = 65536;
      startUid = 100000;
    }];
    packages = with pkgs; with gandhuttt; [
      discord zapzap mpv qbittorrent libreoffice-qt6-fresh thorium steam

      distrobox arduino-ide python310

        (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      ms-vscode-remote.remote-containers
    ];
  })

    ];
  };

  programs.fuse = {
    userAllowOther = true;
  };

  programs.steam = {
    enable = true;
  };

  # Programs and desktop
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    extraPackages = with pkgs; [
      brightnessctl foot grim pulseaudio swayidle swaylock wmenu
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.dconf.enable = true;

  programs.yazi = {
    enable = true;
    settings = {
      yazi.manager.show_hidden = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;

  # Uncomment this to enable greetd instead of a display manager
services.greetd = {
  enable = true;
  package = pkgs.greetd.wlgreet;
  settings = {
    default_session = {
      command = "${pkgs.sway}/bin/sway";
      user = "gandhi";
    };
  };
};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };


  # System version
  system.stateVersion = "25.05";
}

