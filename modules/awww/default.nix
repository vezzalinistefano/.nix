{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Wallpapers live in the home directory, not in the repo: they are megabytes of
  # copyrighted art, not configuration. Drop any 16:9 image in here (stills or gifs).
  dir = "${config.home.homeDirectory}/Pictures/Wallpapers";

  # Pick one at random, with a transition, and remember it so a re-run moves on
  next = pkgs.writeShellApplication {
    name = "wallpaper-next";
    runtimeInputs = [
      pkgs.awww
      pkgs.coreutils
    ];
    text = ''
      dir=${lib.escapeShellArg dir}

      shopt -s nullglob nocaseglob
      files=("$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.webp "$dir"/*.gif)
      if [ "''${#files[@]}" -eq 0 ]; then
        echo "wallpaper-next: no images in $dir" >&2
        exit 1
      fi

      cache="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper"
      last=$(cat "$cache" 2>/dev/null || true)
      pick=$last
      while [ "$pick" = "$last" ] && [ "''${#files[@]}" -gt 1 ]; do
        pick="''${files[RANDOM % ''${#files[@]}]}"
      done

      # Right after login the daemon has the socket but no output yet: wait for it
      for _ in $(seq 20); do
        awww query >/dev/null 2>&1 && break
        sleep 0.25
      done

      awww img "$pick" \
        --transition-type grow \
        --transition-pos 0.5,1.0 \
        --transition-duration 1.4 \
        --transition-fps 60

      mkdir -p "$(dirname "$cache")"
      printf '%s\n' "$pick" > "$cache"
      echo "$pick"
    '';
  };

  # Grow the collection: wallpaper-fetch "cyberpunk anime girl" 10
  fetch = pkgs.writeShellApplication {
    name = "wallpaper-fetch";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      dir=${lib.escapeShellArg dir}
      query="''${1:?usage: wallpaper-fetch <search terms> [count]}"
      count="''${2:-8}"

      mkdir -p "$dir"
      # Wallhaven, safe-for-work only, anime category, 16:9 at least full HD
      encoded=$(jq -rn --arg q "$query" '$q|@uri')
      curl -sf "https://wallhaven.cc/api/v1/search?q=$encoded&categories=010&purity=100&sorting=favorites&atleast=1920x1080&ratios=16x9" \
        | jq -r --argjson n "$count" '.data[:$n][] | .path' \
        | while read -r url; do
            echo "-> ''${url##*/}"
            curl -sfL -O --output-dir "$dir" "$url"
          done
    '';
  };
in
{
  # Wallpaper daemon; the ExecStartPost below puts a random one up when it starts.
  # `-` so an empty folder warns instead of taking the daemon down with it.
  services.awww.enable = true;
  systemd.user.services.awww.Service.ExecStartPost = [ "-${lib.getExe next}" ];

  home.activation.awwwWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg dir}
  '';

  home.packages = [
    next
    fetch
  ];
}
