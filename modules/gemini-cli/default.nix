_:

# gemini-cli is deprecated in nixpkgs: it was replaced by Antigravity CLI, which is what
# the home-manager option `programs.gemini-cli` is being renamed to
# (`programs.antigravity-cli`). The rename is partly landed upstream — the option names
# warn as renamed — but the options do not exist yet at the pinned home-manager, so this
# keeps working through the alias. Switch the module to `programs.antigravity-cli` (its
# settings move to `~/.gemini/antigravity-cli/settings.json`) once
# `nix eval .#darwinConfigurations.SWS000135.options.programs.antigravity-cli.enable`
# resolves.
{
  programs = {
    gemini-cli = {
      enable = true;
      settings = {
        privacy = {
          usageStatisticsEnabled = false;
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
        general = {
          preferredEditor = "nvim";
          previewFeatures = true;
          vimMode = true;
        };
      };
    };
  };
}
