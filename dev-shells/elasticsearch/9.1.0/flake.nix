{
  description = "Elasticsearch 9.1.0 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "aarch64-darwin";
      elasticsystem = "darwin-aarch64";
      pkgs = import nixpkgs { inherit system; };
      version = "9.1.0";

      elasticsearch91 = pkgs.stdenv.mkDerivation {
        name = "elasticsearch-${version}";
        src = pkgs.fetchurl {
          url = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}-${elasticsystem}.tar.gz";
          sha512 = "493f5b50f824b78c4fe69b08f46981e8ad85e6f2fa621c6730a0ad4bc7b5e29d8bf22acc5c243646d4a72ef5953e0ac526a2bcd59c0d4ef17df4eaa5eb9542e2";
        };
        installPhase = ''
          mkdir -p $out
          cp -r * $out/
          chmod +x $out/bin/elasticsearch
        '';
      };

      shellHook = ''
        echo "🚀 Starting development environment..."

        # Create temporary directories for data and logs
        export ES_HOME=$(mktemp -d)
        export ES_DATA=$(mktemp -d)
        export ES_LOGS=$(mktemp -d)

        # Start Elasticsearch
        ${elasticsearch91}/bin/elasticsearch -Epath.data=$ES_DATA -Epath.logs=$ES_LOGS &
        ES_PID=$!
        echo "Elasticsearch started with PID $ES_PID"

        echo "📦 Elasticsearch: http://localhost:9200"
        echo "Run 'exit' toParticipate stop services and clean up."
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          elasticsearch91
        ];
        inherit shellHook;
      };
    };
}
