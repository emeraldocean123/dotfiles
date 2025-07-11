{ config, pkgs, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = with pkgs; [
    oh-my-posh
    fzf
    zoxide
    # Add other packages
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah --color=auto";
      gs = "git status";
      ".." = "cd ..";
    };
    
    bashrcExtra = ''
      # Oh My Posh prompt
      if command -v oh-my-posh &> /dev/null; then
        eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "Joseph";
    userEmail = "emeraldocean123@users.noreply.github.com";
  };

  home.stateVersion = "24.11";
}
