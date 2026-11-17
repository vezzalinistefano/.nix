{
  description = "Reverse engineering lab for the Validity/Synaptics 06cb:009a fingerprint reader";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "validity-re";

        packages = with pkgs; [
          # Looking at the wire
          usbutils
          wireshark # tshark + sharkd; the GUI needs group wireshark
          python3Packages.pyusb

          # Looking at bytes
          hexyl
          vim # xxd
          binwalk
          innoextract # the firmware lives in a Lenovo .exe

          # Looking at code
          rizin # small, scriptable; `rz-bin`, `rz-asm`
          ghidra # heavy, installed on demand by the first shell
          gdb

          # Building a driver
          gcc
          meson
          ninja
          pkg-config
          libusb1
          libfprint
          libfprint-tod
          glib
          openssl
          nss
          pixman
          gusb

          # Replay
          umockdev
          jq
          git
        ];

        shellHook = ''
          echo "validity-re lab — phases in README.md, ground rules first:"
          echo "  1. read the prior art   3. one writer at a time"
          echo "  2. capture, don't guess 4. note state before/after"
          echo
          echo "free the device:  sudo systemctl stop python3-validity open-fprintd"
          echo "descriptors:      ./tools/descriptors.py"
          echo "capture:          sudo ./tools/capture.sh 30"
          echo "dissect:          ./tools/dissect.sh captures/<file>.pcapng"
          echo "probe:            sudo ./tools/probe.py"
        '';
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
