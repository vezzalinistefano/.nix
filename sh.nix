{ config, pkgs, ... }:
let
  myAliases = {
    gadd = "git add -v";
    gaddi = "git add --interactive";
    gcom = "git commit";
    gcomm = "git commit -m";
    gclone = "git clone";
    gcloneclip = "git clone $(getclip)";
    ### logs;
    glog = "git log --all --decorate --oneline --graph";
    glog2 =
      "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
    glo = "git log --oneline";
    gsho = "git show --oneline";
    gsh = "git show";
    gsta = "git status";
    gst = "git status";
    ## Get updates;
    gfa = "git fetch --all";
    gfap = "git fetch --all --prune --prune-tags";
    gpu = "git pull && git submodule update --checkout";
    ### branching;
    gch = "git checkout";
    gchb = "git checkout -b";
    gbd = "git branch -d";
    gbl = "git branch --list";
    gpd = "git push origin --delete";
    gmerg = "git merge --edit --stat --no-ff";
    gmerge = "git merge --edit --stat --no-ff";
    ### submodules;
    gsupc = "git submodule update --checkout";

    vim = "nvim";

    updateNix = "sudo nixos-rebuild switch --flake .#hostname";
    updateHome = "home-manager switch --flake ~/.nix#sv";
    updateHomePlus =
      "sudo -i nix-channel --update && home-manager switch --flake ~/.nix#sv";
  };
in {
  programs.starship = { enable = true; };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
    autosuggestion = { enable = true; };
    syntaxHighlighting.enable = true;
    sessionVariables = { MANPAGER = "nvim +Man!"; };
  };

}
