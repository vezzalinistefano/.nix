{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./sh.nix ./sway.nix ./rice.nix ./nvim ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sv";
  home.homeDirectory = "/home/sv";

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    wget
    neofetch
    grim
    slurp
    wl-clipboard
    haskellPackages.greenclip
    cliphist
    nixfmt-classic
    okular
    xfce.thunar
    spotify
    telegram-desktop
    solaar
    udiskie
    killall
    dig
    ibm-plex
    unzip
    gedit

    papirus-icon-theme

    rustc
    cargo
    python3
    go
    nodejs_23
    gcc
    lua-language-server

    nerd-fonts.sauce-code-pro
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    gnome-font-viewer
  ];

  fonts.fontconfig.enable = true;

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    historyLimit = 10000;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    extraConfig = ''
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Navigate panes with prefix key + Vim motions
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Use Alt-{h,j,k,l} without prefix key to switch panes directly.
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
    '';
  };

  home.file = { };

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  services.gnome-keyring.enable = true;

  programs.firefox = {
    enable = true;
    profiles.sv = {

      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }];

          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      bookmarks = [{
        name = "wikipedia";
        tags = [ "wiki" ];
        keyword = "wiki";
        url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
      }];

      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      userChrome = ''
        /* some css */
      '';

      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        bitwarden
        ublock-origin
        sponsorblock
        darkreader
        tridactyl
        youtube-shorts-block
      ];

    };
  };

  programs.git = {
    enable = true;
    userEmail = "ste.vezzalini@gmail.com";
    userName = "vezzalinistefano";
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = { rebase = true; };
      url = {
        "git@git.sr.ht:" = { insteadOf = [ "https://git.sr.ht/" ]; };
        "git@github.com:" = { insteadOf = [ "https://github.com/" ]; };
        "git@gitlab.com:" = { insteadOf = [ "https://gitlab.com/" ]; };
      };
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
