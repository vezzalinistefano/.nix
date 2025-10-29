{
  description = "NixOS & MacOs configuration of Stefano Vezzalini";

  inputs = {

    # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
    # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # For MacOs
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage neovim configurations and plugins from nix
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      darwin,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      darwinConfigurations = {
        "SWS000154" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/iungo-macbook
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.stefanovezzalini = import ./home/iungo-macbook;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
    };
}
