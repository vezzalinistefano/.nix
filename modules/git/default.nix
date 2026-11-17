_:
let
  personal = import ./personal-identity.nix;
in
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
        inherit (personal) user;

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
