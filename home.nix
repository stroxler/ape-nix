{
  system,
  username,
  pkgs,
  make-homeConfiguration,
  ...
}:
make-homeConfiguration {
  inherit pkgs;
  modules = [
    # Basic metadata
    {
      home = {
        stateVersion = "23.11";
        username = "${username}";
        homeDirectory = "/Users/${username}";
      };
    }
    # Profile packages not managed as programs
    {
      home = {
        packages = [
          pkgs.neovim
          pkgs.ripgrep
          pkgs.tree
          pkgs.eternal-terminal
        ];
      };
    }
    # Dotfiles not managed via nix configs
    {
      home = {
        file = {
          ".config/starship.toml".source = ./dotfiles/starship.toml;
          ".config/gitignore.conf".source = ./dotfiles/gitignore.conf;
          # Note: .inputrc only affects readline using tools, which includes
          # bash but not zsh (bindkey directives control this in zsh).
          ".inputrc".text = ''
            "\e[A": history-search-backward
            "\e[B": history-search-forward
          '';
        };
      };
    }
    {
      programs = {
        home-manager.enable = true;
        bash.enable = true;
        fish.enable = true;
      };
    }
    {
      programs.git = {
        enable = true;
        userName = "Steven Troxler";
        userEmail = "steven.troxler@gmail.com";
        aliases = {
          check = "checkout";
          lg = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(blue)%s%C(reset) - %an%C(reset)%C(bold blue)%d%C(reset)' --all";
        };
        ignores = [
          "result"
        ];
        extraConfig = {
          core = {
            editor = "nvim";
            excludesFile = "~/.config/gitignore.conf";
          };
        };
      };
    }
    {
      programs.zsh = {
        enable = true;
        antidote = {
          enable = true;
          plugins = [
            "zsh-users/zsh-syntax-highlighting"
            "zsh-users/zsh-autosuggestions"
            "zsh-users/zsh-history-substring-search"
          ];
        };
        envExtra = ''
          # Set up/down arrow in zsh
          bindkey '^[[A' history-substring-search-up # or '\eOA'
          bindkey '^[[B' history-substring-search-down # or '\eOB'
        '';
      };
    }
    {
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    }
  ];
}
