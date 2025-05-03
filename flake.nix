{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs { inherit system; };
        # inheriting the inputs from the package massively slows down rust-analyzer, so specify them separately
        buildInputs' = with pkgs; [
          glib
          gtk4
          pango
          librsvg
        ];
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ pkg-config ] ++ buildInputs';

          shellHook = ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${builtins.toString (pkgs.lib.makeLibraryPath buildInputs')}";
          '';
        };

        packages.regreet = pkgs.greetd.regreet.overrideAttrs (old: {
          version = "unstable";
          src = ./.;
        });

        packages.default = packages.regreet;
      }
    );
}
