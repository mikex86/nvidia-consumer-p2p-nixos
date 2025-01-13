# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [
    (import ./overlays/open-gpu-kernel-modules-p2p.nix)
    (import ./overlays/nvidia-565-userlibs.nix)
  ];  

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Force use 6.6 kernel for the entire system
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  
  # Use custom built open-gpu-kernel-modules with p2p support
  boot.extraModulePackages = [
    pkgs.open-gpu-kernel-modules-p2p
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "enp36s0f1" "br0" ];

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Use NVIDIA video drivers
  services.xserver.videoDrivers = [ "nvidia" ];  

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  
  hardware.nvidia.package = pkgs.linuxPackages_6_6.nvidia_x11;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mike = {
    isNormalUser = true;
    description = "mike";
    extraGroups = [ "networkmanager" "wheel" "lxc" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Blacklist Nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  # Disable usb autosuspend
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];
  
  # Force load nvidia kernel modules
  boot.kernelModules = [
  	"nvidia"
  	
  	# nvidia_uvm is required for CUDA to function.
  	# nvidia_uvm is not loaded automatically.
  	# Without a manual nvidia_uvm load rule, CUDA initialization will fail with code=999(cudaErrorUnknown)
  	"nvidia_uvm"
  	
  	"nvidia_modeset"
  ];

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim
     wget
     git
     gnumake
     gcc
     clang
     pciutils
     python312Full
     google-chrome
     betterdiscordctl
  ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable LXD
  virtualisation.lxd.enable = true;
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable IP forwarding
  networking = {
    # Disable DHCP on the physical NIC so that the bridge is the one with an IP
    interfaces.enp36s0f1.useDHCP = false;
    
    # Optionally, if you find that NixOS waits for a carrier, you can set:
    # interfaces.enp36s0f1.requireCarrier = false;

    # Wrap interface enp36s0f1
    bridges.br0.interfaces = [ "enp36s0f1" ];
    
    # Static IP config
    #interfaces.br0.useDHCP = true;
    interfaces.br0.ipv4.addresses = [
      {
        # Set a static IP for the host,
        # Otherwise there is a death spiral where the host is unable to defend its IP lease from a container veth interface on start
        # obtaining new leases ad finitum. I have no idea why this happens and no time to debug this because it is insane.
        address = "10.1.1.67";
        prefixLength = 16;
      }
    ];
    defaultGateway = "10.1.1.1"; # set your gateway here
    nameservers = [ "1.1.1.1" "8.8.8.8" ]; # maybe set your own nameservers

    # Allow port 22 for ssh
    firewall.allowedTCPPorts = [ 22 ];
  };
  
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
