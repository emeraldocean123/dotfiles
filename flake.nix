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
            fzf
            zoxide
          ];

          shellHook = ''
            echo "🧬 Welcome to Joseph's flake shell!"
            export PATH="$HOME/.local/bin:$PATH"

            # Initialize zoxide
            if command -v zoxide &> /dev/null; then
              eval "$(zoxide init bash)"
            fi

            # Set a clean prompt that works with any font
            export PS1='joseph@debian:$(basename "$PWD")$ '
            
            # Clear any existing prompt formatting
            unset PROMPT_COMMAND
            
            # Optional: Initialize Oh My Posh (using theme from dotfiles)
            if command -v oh-my-posh &> /dev/null; then
               eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
            fi
          '';
        };
      });
}
