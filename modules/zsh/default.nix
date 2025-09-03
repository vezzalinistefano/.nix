{ lib, ... }:
let
  myAliases = {
    # git: basics
    gadd = "git add -v";
    gaddi = "git add --interactive";
    gcom = "git commit";
    gcomm = "git commit -m";
    gclone = "git clone";
    gcloneclip = "git clone $(getclip)";
    # git: logs
    glog = "git log --all --decorate --oneline --graph";
    glog2 = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
    glo = "git log --oneline";
    gsho = "git show --oneline";
    gsh = "git show";
    gsta = "git status";
    gst = "git status";
    # git: fetch updated
    gfa = "git fetch --all";
    gfap = "git fetch --all --prune --prune-tags";
    gpu = "git pull && git submodule update --checkout";
    # git:branching
    gch = "git checkout";
    gchb = "git checkout -b";
    gbd = "git branch -d";
    gbl = "git branch --list";
    gpd = "git push origin --delete";
    gmerg = "git merge --edit --stat --no-ff";
    gmerge = "git merge --edit --stat --no-ff";
    # git: submodules
    gsupc = "git submodule update --checkout";
    # vim
    vim = "nvim";
    # vim: git client
    vimg = "nvim +G +only";
    # vim: open current folder
    e = "nvim .";
    # cd ..
    ".." = "cd ..";
    # cd ../..
    "..." = "cd ../..";
    # cd ../../..
    "...." = "cd ../../..";
    # safer cp
    cp = "cp -iv";
    # safer rm
    rm = "rm -Iv";
    # safer mv
    mv = "mv -v";
    # nix: update nixos
    updateNix = "sudo nixos-rebuild switch --flake ~/.nix#jupiter";
    # home-manager: update home
    updateHome = "nixfmt ~/.nix && home-manager switch --flake ~/.nix#sv";
    # home-manager: update home and channel
    updateHomePlus = "sudo -i nix-channel --update && home-manager switch --flake ~/.nix#sv";

    # kubectl
    k = "kubectl";

    ls = "ls --color=auto";
  };
in
{
  programs.starship = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    completionInit = "autoload -Uz compinit && compinit";
    syntaxHighlighting.enable = true;
    sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
    initContent = let zshConfig = lib.mkOrder 1000 "source <(kubectl completion zsh)"; in lib.mkMerge [ zshConfig ];
  };
}
