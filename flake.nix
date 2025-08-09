{
  description = "Joseph's cross-platform dotfiles, managed by Nix Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Use unstable for latest packages
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {
    # This output can be imported by other flakes (like your nixos-config)
    homeManagerModules.default = {
      imports = [ ./home.nix ];
    };

    # This allows you to run `home-manager switch --flake .#joseph@hostname` on non-NixOS machines
    homeConfigurations.joseph = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { };
      modules = [ ./home.nix ];
    };
  };
}
