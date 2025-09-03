{
  description = "Terraform 1.6.6 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      version = "1.6.6";

      terraform166 = pkgs.stdenv.mkDerivation {
        name = "terraform-${version}";
        src = pkgs.fetchzip {
          url = "https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_darwin_arm64.zip";
          hash = "sha256-nZvLd0zCDTqEr/cZJI+ldggaqGV51LfTM9dBAujJFm4=";
        };
        installPhase = ''
          mkdir -p $out/bin
          mv terraform $out/bin/terraform
          chmod +x $out/bin/terraform        
        '';
      };

      shellHook = ''
        alias tf="terraform"
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          terraform166
        ];
        inherit shellHook;
      };
    };
}
