{ ... }:

{
  programs.git = {
    enable = true;
    userEmail = "s.vezzalini@iungo.it";
    userName = "s.vezzalini";
    ignores = [
      ".direnv/*"
      ".envrc"
    ];
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = true;
      };
      url = {
        "git@git.sr.ht:" = {
          insteadOf = [ "https://git.sr.ht/" ];
        };
        "git@github.com:" = {
          insteadOf = [ "https://github.com/" ];
        };
        "git@gitlab.com:" = {
          insteadOf = [ "https://gitlab.com/" ];
        };
      };
    };
  };
}
