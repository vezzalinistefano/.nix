{ lib, ... }:
let
  personal = import ./personal-identity.nix;
in
{
  # Work Macs: commits use the work identity and key everywhere...
  programs.git = {
    settings.user = {
      email = lib.mkForce "s.vezzalini@iungo.it";
      name = lib.mkForce "s.vezzalini";
      signingkey = lib.mkForce "0A1E5F19CCE8DE9357D894CB19421C9B54298D5F";
    };
    # ...except in personal repositories, picked by folder
    includes = [
      {
        condition = "gitdir:~/Projects/personal/";
        contents = personal;
      }
      {
        condition = "gitdir:~/.nix/";
        contents = personal;
      }
    ];
  };
}
