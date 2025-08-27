## flake.nix (dotfiles)
# Home Manager module and formatter for cross-platform dotfiles
{
  description = "Joseph's cross-platform dotfiles, managed by Nix Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Align with main nixos-config for consistency
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    # This output can be imported by other flakes (like your nixos-config)
    homeManagerModules.default = {
      imports = [./home.nix];
    };

    # This allows you to run `home-manager switch --flake .#joseph@hostname` on non-NixOS machines
    homeConfigurations.joseph = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {};
      modules = [./home.nix];
    };
  };
}
