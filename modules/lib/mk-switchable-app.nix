# Builds the two halves of an app that can be installed either by nix or by Homebrew.
# The switch is the darwin option `apps.<name>.source`; override it per host with
#   apps.<name>.source = "nix" | "homebrew";
#
# `home`   -> home-manager module, installs the nixpkgs package when source == "nix"
# `darwin` -> nix-darwin module, declares the option and adds the cask when source == "homebrew"
{
  name,
  package ? name,
  cask ? name,
  default ? "nix",
}:
{
  darwin =
    { config, lib, ... }:
    {
      options.apps.${name}.source = lib.mkOption {
        type = lib.types.enum [
          "nix"
          "homebrew"
        ];
        inherit default;
        description = "Where ${name} is installed from.";
      };

      config = lib.mkIf (config.apps.${name}.source == "homebrew") {
        homebrew.casks = [ cask ];
      };
    };

  home =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      home.packages = lib.optional (osConfig.apps.${name}.source == "nix") pkgs.${package};
    };
}
