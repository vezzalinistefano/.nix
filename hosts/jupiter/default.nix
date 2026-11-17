# jupiter: x86_64 physical server (Giga-byte board, Ryzen 5 2600, 15 GiB RAM)
# that today runs Proxmox 9 on the NVMe (hostname `solaris`, 192.168.1.35).
# Headless: SSH, avahi and autoUpgrade, no desktop. The Samsung SATA disk holds
# a Windows install and is left alone. Installed with nixos-anywhere, see
# docs/wiki/jupiter-setup.md.
{
  config,
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "jupiter";

  # The machine boots in UEFI mode, so systemd-boot on the ESP from disko.nix.
  # (Its Windows disk has its own ESP; firmware entries survive untouched.)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Server: no swap partition and no disk passphrase, so a reboot needs nothing
  # typed on a keyboard. See ./disko.nix for what to change to add LUKS.
  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;
  services.fstrim.enable = true;

  # Wired DHCP or Wi-Fi (on the console: `nmtui`)
  networking.networkmanager.enable = true;

  # Announces jupiter.local on the LAN, so `nrs jupiter` needs no fixed address.
  # A DHCP reservation in the router is still worth it.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
    };
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "it";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Lets `nrs jupiter` copy the closure in and build it here as this user
  nix.settings.trusted-users = [ username ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    # No password: the SSH key is the only way in, and sudo cannot ask for a
    # password that does not exist (security.sudo.wheelNeedsPassword below), so
    # `nrs jupiter` only needs an empty answer at its password prompt. Set one
    # later with `passwd` if you want a second factor for sudo, then turn that
    # option off.
    # Machines allowed to log in and deploy (one entry per client device)
    openssh.authorizedKeys.keys = [
      # SWS000135
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1Pp4h+E9om/+f2f9iFksK+KVFWnX4RVyLkr6OUHEbY"
      # callisto (this machine, for nrs/nixos-anywhere from here)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7L0TDuzEqJew/LHoD1qFaFwiS/yUsjxy5gmj+DLDUi sv@callisto"
    ];
  };
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # Key-only SSH, limited to the one user; this is how the Macs deploy
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ username ];
    };
  };

  # Follows the gated `release` branch on GitHub, like callisto: CI only moves
  # it for a green `main`, and jupiter builds and switches to it once a day.
  # Never reboots by itself. Run it now: `sudo systemctl start nixos-upgrade`
  system.autoUpgrade = {
    enable = true;
    flake = "github:vezzalinistefano/.nix/release#${config.networking.hostName}";
    dates = "daily";
    persistent = true;
    randomizedDelaySec = "10min";
    operation = "switch";
    allowReboot = false;
  };

  # Firmware updates: `fwupdmgr refresh && fwupdmgr update`
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
  environment.variables.EDITOR = "nvim";

  system.stateVersion = "26.05";
}
