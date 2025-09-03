{
  description = "Docker environment flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin"; # Adjust for your system (e.g., "aarch64-darwin" for macOS)
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [];
        shellHook = ''
          docker compose up -d --remove-orphans

          trap \
            "
              docker compose down
            " \
            EXIT
        '';
      };
    };
}
