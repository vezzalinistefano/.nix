{ pkgs, ... }:
let
  # API keys, decrypted by sops-nix on the host (see hosts/callisto: sops.secrets).
  # opencode finds a provider by its environment variable, so no key is written in its config.
  keys = {
    DEEPSEEK_API_KEY = "/run/secrets/deepseek-api-key";
    VENICE_API_KEY = "/run/secrets/venice-api-key";
  };

  # Only opencode sees the keys: they are read when it starts, not exported in every shell
  loadKeys = pkgs.lib.concatStringsSep "\n" (
    pkgs.lib.mapAttrsToList (var: file: ''
      if [ -r ${file} ]; then export ${var}="$(cat ${file})"; fi
    '') keys
  );
in
{
  # Terminal coding agent. Pick a model inside it with /models (DeepSeek and Venice AI appear
  # once their keys are set with scripts/set-secret.sh)
  home.packages = [
    (pkgs.writeShellScriptBin "opencode" ''
      ${loadKeys}
      exec ${pkgs.opencode}/bin/opencode "$@"
    '')
  ];
}
