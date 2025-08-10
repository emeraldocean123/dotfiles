# Dotfiles

Cross-platform shell and prompt configuration for Bash and PowerShell, with a Home Manager module for Linux.

## Structure

	- Microsoft.PowerShell_profile.ps1: User profile that boots a vendored PSReadLine and sets up Oh My Posh.
	- profile.bootstrap.ps1: Loads PSReadLine 2.4.1 from modules/PSReadLine/2.4.1.

## Quick use

	- Run bootstrap.ps1 in an elevated PowerShell to install tools and copy profile.
	- Profiles load the vendored PSReadLine and Oh My Posh theme automatically.

	- Use this repo as a flake: `home-manager switch --flake .#joseph` or import `homeManagerModules.default` in your system flake.

## Notes

Unified Oh My Posh theme:

- Single source of truth: `posh-themes/jandedobbeleer.omp.json` in this repo.
- PowerShell profile loads it directly from `Documents/dotfiles`.
- NixOS/Home Manager setups can reference it via a flake input. Example in `nixos-config`:
	- Add input: `dotfiles.url = "path:../dotfiles";`
	- Link theme in Home Manager module using `inputs.dotfiles.outPath + "/posh-themes/jandedobbeleer.omp.json"`.


## Formatting & linting (optional)

If you have Nix installed, you can:

- Run formatter: `nix fmt` (uses nixpkgs-fmt)
- Enter dev shell: `nix develop` (provides nixpkgs-fmt)

On Windows without Nix, use WSL (Ubuntu) with Nix installed, or skip.
- Theme path is shared across environments; keep the single theme file in posh-themes/.
