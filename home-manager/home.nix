{
  system,
  username,
  pkgs,
  make-homeConfiguration,
  ...
}: let
  homeDirectory =
    if (builtins.elemAt (builtins.split "-" system) 2) == "darwin"
    then "/Users/${username}"
    else "/home/${username}";
  shellProfileExtra = ''
    # Load vanilla nix profile, if it exists
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    # Load home-manager session vars, if they exist
    if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    	. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi

    # Put binaries on path
    export PATH="$HOME/bin:$PATH"
  '';
in
  make-homeConfiguration {
    inherit pkgs;
    modules = [
      # Basic metadata
      {
        home = {
          stateVersion = "23.11";
          username = "${username}";
          inherit homeDirectory;
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
        };
      }
      {
        programs.bat = {
          enable = true;
          #extraPackages = with pkgs.bat-extras; [ batman batgrep ];
          config = {
            theme = "Dracula"; # I like the TwoDark colors better, but want bold/italic in markdown docs
            #pager = "less -FR";
            pager = "page -WO -q 90000";
            italic-text = "always";
            style = "plain"; # no line numbers, git status, etc... more like cat with colors
          };
        };
      }
      {
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          nix-direnv.enable = true;
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
        programs.bash = {
          enable = true;
          profileExtra = shellProfileExtra;
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
          profileExtra = shellProfileExtra;
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
