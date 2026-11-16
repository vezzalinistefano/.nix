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

    # Declarative disk partitioning, used by nixos-anywhere to install NixOS hosts remotely
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Decrypts the secrets kept in ./secrets when a NixOS host is activated
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware quirks per laptop model (callisto is a ThinkPad T480)
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Native Spotify client, not in nixpkgs. The Macs get it from the Homebrew tap
    # (modules/spotifast/darwin.nix); callisto builds this from source.
    spotifast = {
      url = "github:crmne/spotifast/v0.17.1";
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
      nixpkgs,
      darwin,
      home-manager,
      ...
    }:
    let
      # Every host shares ./home/common. The Macs also share ./hosts/common, and
      # ./hosts/<hostname> only holds their machine-specific overrides.
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
              home-manager.users.${username}.imports = [
                ./home/common
                ./home/darwin
                ./home/work
              ];
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

      # NixOS hosts keep their whole system configuration in ./hosts/<hostname>.
      mkNixosHost =
        {
          hostname,
          system ? "x86_64-linux",
          username ? "sv",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.${username}.imports = [
                ./home/common
                ./home/linux
              ];
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        "SWS000135" = mkDarwinHost { hostname = "SWS000135"; };
      };

      nixosConfigurations = {
        "callisto" = mkNixosHost { hostname = "callisto"; };
      };

      # `nix fmt` formats every .nix file in the repo with nixfmt
      formatter.aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
