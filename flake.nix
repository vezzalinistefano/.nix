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

    # Terminal workspace manager for AI coding agents, not packaged in nixpkgs.
    # nixpkgs is not followed: upstream needs zig_0_16 and a pinned rust toolchain
    herdr = {
      url = "github:herdrdev/herdr/v0.9.3";
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
    let
      # Every host shares ./hosts/common and ./home/common;
      # ./hosts/<hostname> only holds machine-specific overrides.
      mkDarwinHost =
        {
          hostname,
          system ? "aarch64-darwin",
          username ? "stefanovezzalini",
        }:
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/common;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        "SWS000154" = mkDarwinHost { hostname = "SWS000154"; };
        "SWS000135" = mkDarwinHost { hostname = "SWS000135"; };
      };

      # `nix fmt` formats every .nix file in the repo with nixfmt
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
