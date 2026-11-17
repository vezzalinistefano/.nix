_:

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
        # Personal identity; the work Macs replace it in ./work.nix
        user = {
          email = "ste.vezzalini@gmail.com";
          name = "Stefano Vezzalini";
          signingkey = "C2006DA935947D3CA6B775E3003005400C7C7B2F";
        };
        # Sign every commit and tag with the GPG key above. See docs/wiki/gpg-vademecum.md
        commit.gpgsign = true;
        tag.gpgsign = true;
        init = {
          defaultBranch = "main";
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
