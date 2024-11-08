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

    # Put binaries on path. I tend to use ~/bin for standard tools and
    # ~/local for adhoc or project-specific stuff.
    export PATH="$HOME/local:$HOME/bin:$PATH"
  '';
  zshProfileExtra = ''
    if [ -e "$HOME/.zsh_plugins.zsh" ]; then
      source ~/.zsh_plugins.zsh

      # Set up/down arrow in zsh to be fish-like
      bindkey '^[[A' history-substring-search-up # or '\eOA'
      bindkey '^[[B' history-substring-search-down # or '\eOB'
    else
      alias antidote-bundle='antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh'
      echo 'No antidote plugins found. Assuming ssh is set up, run antidote-bundle to pull.'
    fi

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
          };
          profileExtra = shellProfileExtra + zshProfileExtra;
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
      # Dotfiles not managed via nix configs
      {
        home = {
          file = {
            ".config/starship.toml".source = ./dotfiles/starship.toml;
            ".config/gitignore.conf".source = ./dotfiles/gitignore.conf;
            ".zsh_plugins.txt".source = ./dotfiles/.zsh_plugins.txt;
            ".vimrc".source = ./dotfiles/.vimrc;
            ".wezterm.lua".text = ''
              local wezterm = require 'wezterm'
              local config = wezterm.config_builder()
              config.color_scheme = 'Spacedust (Gogh)'
              config.keys = {
                {
                  key = 'd',
                  mods = 'CMD',
                  action = wezterm.action.SplitHorizontal,
                 },
              }
              return config
            '';
            # Note: .inputrc only affects readline using tools, which includes
            # bash but not zsh (bindkey directives control this in zsh).
            ".inputrc".text = ''
              "\e[A": history-search-backward
              "\e[B": history-search-forward
            '';
          };
        };
      }
    ];
  }
