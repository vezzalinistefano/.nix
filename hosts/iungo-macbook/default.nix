{
  pkgs,
  lib,
  ...
}:
{
  networking = {
    hostName = "SWS000154";
  };

  # enable flakes globally
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "stefanovezzalini" ];

  services.yabai = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use this instead of services.nix-daemon.enable if you
  # don't wan't the daemon service to be managed for you.
  # nix.useDaemon = true;
  nix.enable = true;

  nix.package = pkgs.nix;

  programs.nix-index.enable = true;

  # boot.loader.grub.configurationLimit = 10;
  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.optimise.automatic = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  # Set your time zone.
  # comment this due to the issue:
  #   https://github.com/LnL7/nix-darwin/issues/359
  # time.timeZone = "Asia/shanghai";

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  environment.variables = {
    EDITOR = "nvim";
    GOPATH = "/Users/stefanovezzalini/go";
    NIXPATH = "/etc/nix-darwin";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stefanovezzalini = {
    home = "/Users/stefanovezzalini";
    description = "stefanovezzalini";

    # set user's default shell back to zsh
    #    `chsh -s /bin/zsh`
    # DO NOT change the system's default shell to nushell! it will break some apps!
    # It's better to change only starship/alacritty/vscode's shell to nushell!
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  system.stateVersion = 6;
  system.primaryUser = "stefanovezzalini";
}
