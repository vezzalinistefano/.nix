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
    # API keys for opencode (modules/opencode), readable by the user only.
    # Set them with: scripts/set-secret.sh callisto <name>
    secrets."deepseek-api-key".owner = username;
    secrets."venice-api-key".owner = username;
    # Backup credentials (services.restic.backups), readable by root only
    secrets."restic-password".sopsFile = ../../secrets/restic.yaml;
    secrets."restic-env".sopsFile = ../../secrets/restic.yaml;
  };
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Compressed swap in RAM; there is no swap partition
  zramSwap.enable = true;

  # ext4 on an SSD: trim weekly and drop /tmp at boot
  services.fstrim.enable = true;
  boot.tmp.cleanOnBoot = true;

  # Nightly encrypted backup of the home directory to Backblaze B2 (bucket "callisto",
  # region eu-central-003, one app key for it). Restic dedupes and encrypts client-side,
  # the passphrase and key come from secrets/restic.yaml. Retention stays above B2's
  # 30-day minimum before data can be deleted. Restore: see docs/wiki/nixos-host-setup.md
  services.restic.backups.b2 = {
    initialize = true;
    repository = "s3:https://s3.eu-central-003.backblazeb2.com/callisto";
    passwordFile = config.sops.secrets."restic-password".path;
    environmentFile = config.sops.secrets."restic-env".path;
    paths = [ config.users.users.${username}.home ];
    # Rebuildable or huge, and reproducible from the flake: not worth the upload
    exclude = [
      "/home/${username}/.cache"
      "/home/${username}/.local/share/Trash"
      "/home/${username}/.local/share/containers"
      "/home/${username}/.direnv"
      "/home/${username}/.mozilla/firefox/*/cache2"
      "/home/${username}/.config/BraveSoftware/*/Cache"
      "/home/${username}/.local/share/Steam"
      "**/node_modules"
      "**/target"
      "**/.direnv"
      "**/result"
      "**/result-*"
    ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
  };

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

  # Plugged in, closing the lid does not suspend: the laptop stays reachable over SSH and
  # keeps driving an external monitor. On battery the lid still suspends it.
  services.logind.settings.Login = {
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Power: balanced/power-saver/performance profiles (`powerprofilesctl`) and Intel thermal control
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # Lets GTK apps and browsers read the dark-mode preference and open GTK file dialogs
  programs.dconf.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Password store for apps (Secret Service): browsers and other apps keep sign-ins here.
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
  # Follows the gated `release` branch on GitHub, which CI only advances for a green
  # `main`: once a day (or at the next boot if it was off) it builds what was pushed and
  # switches to it. Versions come from the committed flake.lock, so nothing changes unless
  # it was pushed. Run it now: `sudo systemctl start nixos-upgrade`
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
