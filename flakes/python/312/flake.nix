{
  description = "Python 3.12 development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin"; # Adjust for your system (e.g., "aarch64-darwin" for macOS)
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.python312
          pkgs.python312Packages.pip
          pkgs.python312Packages.virtualenv
          pkgs.python312Packages.black
        ];
        shellHook = ''
          VENV=.venv

          if test ! -d $VENV; then
            python3.12 -m venv $VENV
          fi
          source ./$VENV/bin/activate

          if test -f ./requirements.txt; then
            pip install -r requirements.txt
          fi
        '';
      };
    };
}
