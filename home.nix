# This is the single source of truth for Joseph's cross-platform shell environment.
# home.nix (dotfiles)
# Home Manager module defining shared shell packages and theme link
{pkgs, ...}: {
  # Set home-manager state version
  home.stateVersion = "25.05";

  # Install user-specific packages, cross-referenced with search.nixos.org
  home.packages = with pkgs; [
    oh-my-posh
    fzf
    zoxide
  ];

  # Configure Bash shell
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -f "$HOME/.bashrc" ]; then
          . "$HOME/.bashrc"
      fi
    '';
    initExtra = ''
      # Add user's local bin to PATH for locally installed tools.
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
      fi

      # Initialize zoxide (for `z` command).
      eval "$(zoxide init bash)"

      # Initialize Oh My Posh prompt.
      eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/jandedobbeleer.omp.json)"
    '';
    shellAliases = {
      ll = "ls -lah --color=auto";
      la = "ls -A --color=auto";
      gs = "git status";
      gp = "git push";
      gl = "git log --oneline -10";
      gd = "git diff";
      ".." = "cd ..";
      reload = "exec bash";
    };
  };

  # Configure Git
  programs.git = {
    enable = true;
    userName = "Joseph";
    userEmail = "emeraldocean123@users.noreply.github.com";
    extraConfig.pull.rebase = true;
  };

  # Configure fzf
  programs.fzf.enable = true;

  # Link the Oh My Posh theme file
  home.file.".config/oh-my-posh/jandedobbeleer.omp.json".source = ./posh-themes/jandedobbeleer.omp.json;
}
