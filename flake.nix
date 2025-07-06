{
  description = "Joseph's portable shell environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "joseph-shell";

          packages = with pkgs; [
            git
            curl
            wget
            unzip
            nano
            oh-my-posh
          ];

          shellHook = ''
            echo "🧬 Welcome to Joseph's flake shell!"
            export PATH="$HOME/.local/bin:$PATH"
          '';
        };
      });
}
