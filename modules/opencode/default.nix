_:

{
  programs = {
    opencode = {
      enable = true;
      settings = {
        # Version is pinned by nixpkgs; don't let opencode update itself
        autoupdate = false;
        share = "disabled";
      };
    };
  };
}
