# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let
  sddm-astronaut = pkgs.sddm-astronaut.override {
	embeddedTheme = "japanese_aesthetic";
	#themeConfig = {
	 # HeaderTextColor = "#d5c4a1";
	 # Background = "home/schmoetyyy/wallpapers/Faroeste.jpg";
	#};
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
#  boot.kernelParams = [ "fsck.mode=force" ];
#  boot.initrd.checkJournalingFS = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "snowline"; # Define your hostname.

  fileSystems."/home/schmoetyyy/HDD" = {
  device = "/dev/disk/by-uuid/110e5c9a-f0da-4e3a-93e9-c6b908822ba7";
  fsType = "ext4";  # oder ntfs, btrfs, etc. – je nach Dateisystem der HDD
  options = [ "nofail" "x-systemd.automount"];
};

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Jetbrains Mono";
     keyMap = "de";
    # useXkbConfig = true; # use xkb.options in tty.
   };

    nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
  };


  services.xserver.xkb.layout = "de";
  services.xserver.enable = true;
  security.rtkit.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

   services.pipewire = {
     enable = true;
     pulse.enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
   };
   hardware.bluetooth.enable = true;
   services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.schmoetyyy = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
   };


  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm; 
    wayland.enable = true;
    extraPackages = [ sddm-astronaut ];
    theme = "sddm-astronaut-theme";
  };
  services.gnome.gnome-keyring.enable = true; 
  security.pam.services.sddm.enableGnomeKeyring = true;

  programs.firefox.enable = true;
  programs.localsend.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.steam.enable = true;

nix.extraOptions = ''
  !include ~/.security/nixos/github-token.conf
'';

   environment.systemPackages = with pkgs; [
     vim
     wget
     kitty
     fastfetch
     zed-editor
     tree
     git
     zip
     unzip
     xdg-user-dirs
     nwg-look
     rofi
     qogir-icon-theme
     hyprpaper
     pavucontrol
     sddm-astronaut
     protonup-qt
     prismlauncher
     file-roller
     spotify
     discord
     pinta
     seahorse
     yazi
     swaynotificationcenter
     cliphist
     wl-clipboard
     sassc
     hyprpicker
     networkmanagerapplet
     networkmanager_dmenu
     networkmanager-openvpn
     networkmanager-l2tp
     networkmanager-strongswan
     gimp
     vlc
     waybar
     resources
     wl-crosshair
     ] ++ [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
     ];

  fonts.packages = with pkgs; [
     nerd-fonts.jetbrains-mono
     jetbrains-mono
     nerd-fonts.iosevka
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

 networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}


