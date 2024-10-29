{
  description = "TUI Audiobook player written in Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        buildInputs = with pkgs; [
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          pkg-config
        ];

        nativeBuildInputs = with pkgs; [
          rust-bin.stable.latest.default
          pkg-config
        ];
      in {
        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;

          shellHook = ''
            echo "Rust development environment"
          '';
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "gadacz";
          version = "0.1.0";
          src = ./.;

          inherit buildInputs;

          cargoLock.lockFile = ./Cargo.lock;

          # Optional: if you need to skip the checkPhase
          doCheck = false;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          exePath = "/bin/gadacz";
        };
      }
    );
}
