let
  sources = import ../npins;
in
{
  pkgs,
  lib,
  ...
}:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thonkpad-nix";
  networking.networkmanager.enable = true;
  # Enable mDNS
  services.avahi = {
    nssmdns4 = true;
    nssmdns6 = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  time.timeZone = "Canada/Eastern";
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_CA.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_CA.UTF-8";
    LC_IDENTIFICATION = "en_CA.UTF-8";
    LC_MEASUREMENT = "en_CA.UTF-8";
    LC_MONETARY = "en_CA.UTF-8";
    LC_NAME = "en_CA.UTF-8";
    LC_NUMERIC = "en_CA.UTF-8";
    LC_PAPER = "en_CA.UTF-8";
    LC_TELEPHONE = "en_CA.UTF-8";
    LC_TIME = "en_CA.UTF-8";
  };
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      kdePackages.fcitx5-qt
    ];
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
  services.flatpak.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  services.fwupd.enable = true;
  services.tailscale.enable = true;
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  virtualisation.waydroid.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.vmware.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "me" ];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
  };
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.settings = {
  #   General = {
  #     Experimental = true;
  #   };
  # };
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  users.users.me = {
    isNormalUser = true;
    description = "Em";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "dialout"
      "podman"
    ];
  };
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-monochrome-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      corefonts
      fira-code
      cascadia-code
      roboto
      inter
    ];
  };
  environment.systemPackages = with pkgs; [
    p7zip
    moreutils
    git
    nano
    # (busybox // { meta.priority = 30; })
    iw
    pv
    libglvnd
    libx11
    fontconfig
  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    SDL2
    SDL2_image
    SDL2_ttf
  ];
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [
    ];
  };
  environment.defaultPackages = [ ];
  environment.extraInit = ''
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  '';
  # Open ports in the firewall.
  # slsk
  #networking.firewall.allowedTCPPorts = [ 2234 ];
  #networking.firewall.allowedUDPPorts = [ 2234 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    (builtins.match "^.*(firmware|facetimehd|mullvad|firefox).*$|corefonts" (lib.getName pkg)) != null;
  nix.package = pkgs.lix;
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
    # "https://cache.dataaturservice.se/spectrum/"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
  ];
  nix.settings.allowed-users = [
    "@wheel"
  ];

  # https://jade.fyi/blog/pinning-nixos-with-npins/
  # > We need the flakes experimental feature to do the NIX_PATH thing cleanly
  # > below. Given that this is literally the default config for flake-based
  # > NixOS installations in the upcoming NixOS 24.05, future Nix/Lix releases
  # > will not get away with breaking it.
  nix.settings.experimental-features = "nix-command flakes";
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
  nixpkgs.flake.source = sources.nixpkgs;

  security.sudo.execWheelOnly = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
  # Did you read the comment?
}
