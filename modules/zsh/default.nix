{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # Where this repo sits: /private/etc/nix-darwin on the Macs, a clone in the home
  # directory on the NixOS host.
  repoPath = if isDarwin then "/private/etc/nix-darwin" else "$HOME/.nix";

  # Rebuild shortcuts differ per system: the Macs rebuild themselves with darwin-rebuild and
  # deploy NixOS hosts over SSH; a NixOS host rebuilds itself from its own clone in ~/.nix
  rebuildAliases =
    if isDarwin then
      {
        # nix-darwin: rebuild and switch
        drs = "sudo darwin-rebuild switch --flake ${repoPath}";
        # nix-darwin: build without switching (test first)
        drb = "darwin-rebuild build --flake ${repoPath}";
        # nix-darwin: run the flake checks (formatting, scripts, evaluation)
        drc = "nix flake check ${repoPath}";
        # nix-darwin: update packages and rebuild
        dru = "nix flake update --flake ${repoPath} && sudo darwin-rebuild switch --flake ${repoPath}";
        # nix-darwin: format nix files
        drf = "nix fmt ${repoPath}";
        # NixOS hosts, deployed from this Mac: build on the host itself and switch (asks for its sudo password)
        nrs = "nixos-deploy switch";
        # NixOS hosts: build and activate without making it the boot default (a reboot undoes it)
        nrt = "nixos-deploy test";
      }
    else
      {
        # NixOS: rebuild this machine from its clone and switch
        nrs = "sudo nixos-rebuild switch --flake ${repoPath}";
        # NixOS: build and activate without making it the boot default (a reboot undoes it)
        nrt = "sudo nixos-rebuild test --flake ${repoPath}";
        # NixOS: build only, to check a change
        nrb = "nixos-rebuild build --flake ${repoPath}";
      };

  # kubectl and argocd come from ../work, which only the Macs import
  workAliases =
    if isDarwin then
      {
        k = "kubectl";
        kctx = "kubectl config use-context $(kubectl config get-contexts --no-headers| awk '{print $2}' | fzf)";
        argocd = "argocd --grpc-web";
      }
    else
      { };

  myAliases =
    rebuildAliases
    // workAliases
    // {
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
      gfrm = "git fetch --all --prune --prune-tags && git rebase origin/main";
      gpu = "git pull && git submodule update --checkout";
      # git:branching
      gch = "git checkout";
      gchb = "git checkout -b";
      gbd = "git branch -d";
      gbl = "git branch --list";
      gp = "git push";
      gpd = "git push origin --delete";
      gmerg = "git merge --edit --stat --no-ff";
      gmerge = "git merge --edit --stat --no-ff";
      gcpx = "git cherry-pick -x";
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

      git-list-untracked = "git fetch --prune && git branch -r | awk \"{print \$1}\" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk \"{print \$1}\"";
      git-remove-untracked = "git fetch --prune && git branch -r | awk \"{print \$1}\" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk \"{print \$1}\" | xargs git branch -d";

      # kubectl and argocd moved into workAliases above, they only exist on the Macs
      ls = if isDarwin then "ls -G" else "ls --color=auto";

      sg = "ast-grep";

      # claude code session reachable from a telegram bot
      tg = "claude --channels plugin:telegram@claude-plugins-official";

      # Fuzzy finding
      cdf = "cd $(find . -type d 2> /dev/null | fzf)"; # fuzzy find from current directory
      cdw = "cd $(git worktree list | awk '{ print $1 }' | fzf)"; # fuzzy find across git worktrees
      cdg = "cd $(ghq list -p | fzf)"; # fuzzy find across all ghq-managed repos
    };
in
{
  # The worktree/branch cleanup called by the shell function below; packaged so both
  # platforms find it on PATH instead of through a hardcoded repo path
  home.packages = [
    (pkgs.writeShellScriptBin "git-cleanup-orphaned.sh" (
      builtins.readFile ../../scripts/git-cleanup-orphaned.sh
    ))
  ];

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
    # compinit's security scan and cache rebuild are the slow part of shell startup:
    # do them at most once a day and load the cached dump otherwise.
    # After adding a tool, its completions can take up to a day to show (or run `compinit`).
    completionInit = ''
      autoload -Uz compinit
      () {
        local dump=''${ZDOTDIR:-$HOME}/.zcompdump
        local -a stale=($dump(N.mh+24))
        if [[ ! -e $dump || -n $stale ]]; then compinit; else compinit -C; fi
      }
    '';
    syntaxHighlighting.enable = true;
    sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
    initContent =
      let
        zshConfig = lib.mkOrder 1000 ''
          # Cycle through completions using arrow keys
          zstyle ':completion:*' menu select

          clean-worktrees() {
            git worktree list --porcelain |
              grep '^worktree ' |
              cut -d' ' -f2 |
              while read wt; do
                branch=$(git -C "$wt" branch --show-current)
                if [ -n "$branch" ] && ! git branch -r --contains "$branch" | grep -q .; then
                  echo "Removing $wt ($branch)"
                  git worktree remove "$wt" --force
                fi
              done
          }

          # nrs <host> / nrt <host>: push this flake's NixOS config to a host over SSH.
          # Runs on the Mac (nixos-rebuild comes from home/darwin); the host builds its own closure.
          # The SSH destination defaults to sv@<host>.local, pass another as the second argument.
          nixos-deploy() {
            local action=$1 host=''${2:?usage: nrs|nrt <host> [ssh-destination]}
            local dest=''${3:-sv@$host.local}
            nixos-rebuild "$action" --no-reexec \
              --flake "${repoPath}#$host" \
              --target-host "$dest" --build-host "$dest" \
              --sudo --ask-sudo-password
          }

          # The script is on PATH (packaged below), so the path does not matter
          git-cleanup-orphaned() {
            git-cleanup-orphaned.sh "$@"
          }

          # Fuzzy-pick a git repo or worktree and open/attach its tmux session
          tmux-sessionizer() {
            local -a roots
            if [ -n "$PROJECT_ROOTS" ]; then
              roots=(''${=PROJECT_ROOTS})
            else
              roots=("$HOME/projects" ${repoPath})
            fi

            local dir
            dir=$(
              fd --hidden --no-ignore --max-depth 6 --type d --type f '^\.git$' "''${roots[@]}" 2>/dev/null |
                sed 's|/\.git/\{0,1\}$||' |
                sort -u |
                fzf --prompt='project > ' --height=60% --reverse \
                    --preview 'git -C {} log --oneline --decorate -15 --color=always 2>/dev/null'
            ) || return
            [ -n "$dir" ] || return

            # Repos split across worktrees share a parent dir, so their basenames
            # collide (master, feat/..., fix/...): name those <parent>/<path below it>
            local name common container
            common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
            container=$(dirname "$(dirname "$common")")
            name=$(basename "$dir")
            if [ -n "$common" ] && [ "$(git -C "$dir" worktree list | wc -l)" -gt 1 ]; then
              case "$dir" in
                "$container"/*) name="$(basename "$container")/''${dir#$container/}" ;;
              esac
            fi
            # tmux forbids '.' and ':' in session names
            name=''${name//[.:]/_}

            # New sessions open as nvim | claude
            if ! tmux has-session -t="$name" 2>/dev/null; then
              tmux-dev-layout "$dir" "$(tmux new-session -ds "$name" -c "$dir" -P -F '#{pane_id}')"
            fi
            if [ -n "$TMUX" ]; then
              tmux switch-client -t "$name"
            else
              tmux attach-session -t "$name"
            fi
          }

          gcpxf() {
            git log --oneline --all --color=always |
              fzf -m --ansi --preview 'git show --color=always {1}' --preview-window=right:60% |
              awk '{ print $1 }' |
              xargs -r git cherry-pick -x
          }

          bindkey -s '^f' 'tmux-sessionizer\n'

          bindkey '^[[A' history-search-backward
          bindkey '^[[B' history-search-forward
        '';
      in
      lib.mkMerge [ zshConfig ];
  };
}
