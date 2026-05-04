{ ... }:

{
  programs = {
    git = {
      enable = true;
      ignores = [
        ".direnv/*"
        ".envrc"
        ".DS_STORE"
      ];
      settings = {
        user = {
          email = "s.vezzalini@iungo.it";
          name = "s.vezzalini";
        };
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
  };
}
