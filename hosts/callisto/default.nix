# callisto: ThinkPad T480 running NixOS with Hyprland. Installed and updated
# remotely from the Macs, see docs/wiki/nixos-host-setup.md.
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
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
    inputs.sops-nix.nixosModules.sops
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "callisto";

  # Secrets live encrypted in secrets/callisto.yaml (who can read them: .sops.yaml).
  # callisto decrypts them with its SSH host key when the system is activated.
  sops = {
    defaultSopsFile = ../../secrets/callisto.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets."${username}-password".neededForUsers = true;
  };
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Compressed swap in RAM; there is no swap partition
  zramSwap.enable = true;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "it";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Lets `nrs callisto` copy the closure in and build it here as this user
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
      "video"
    ];
    shell = pkgs.zsh;
    # Password given to the account when it is first created (a reinstall); afterwards
    # `passwd` changes it. Set the stored one with scripts/set-user-password.sh
    hashedPasswordFile = config.sops.secrets."${username}-password".path;
    # Machines allowed to log in and deploy (one entry per client device)
    openssh.authorizedKeys.keys = [
      # SWS000135
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1Pp4h+E9om/+f2f9iFksK+KVFWnX4RVyLkr6OUHEbY"
    ];
  };
  programs.zsh.enable = true;

  # Key-only SSH, limited to the one user; this is how the Macs deploy
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ username ];
    };
  };

  # Announces callisto.local on the LAN, so no fixed IP is needed
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
    };
  };

  # Desktop: Hyprland here, its configuration in modules/hyprland (home-manager)
  programs.hyprland.enable = true;

  # The disk passphrase is the login: boot straight into Hyprland as the user.
  # Logging out lands on a text greeter.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${config.programs.hyprland.package}/bin/start-hyprland";
        user = username;
      };
      default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${config.programs.hyprland.package}/bin/start-hyprland";
    };
  };

  # Password store for apps (Secret Service). Spotifast keeps its sign-in here.
  # With auto-login nothing unlocks it at boot: give the keyring an empty password
  # when it first asks, the disk encryption already protects it.
  services.gnome.gnome-keyring.enable = true;

  # Lets hyprlock (modules/hyprlock) check the password
  security.pam.services.hyprlock = { };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  # Firmware updates: `fwupdmgr refresh && fwupdmgr update`
  services.fwupd.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.hack
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
  environment.variables.EDITOR = "nvim";

  system.stateVersion = "26.05";
}
