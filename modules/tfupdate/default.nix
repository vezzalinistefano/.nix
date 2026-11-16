{ pkgs, ... }:
{
  home.packages = [
    # Not in the binary cache for this nixpkgs pin, so it builds here; its tests download
    # Terraform providers and fail on a checksum, so they are skipped
    (pkgs.tfupdate.overrideAttrs { doCheck = false; })
  ];
}
