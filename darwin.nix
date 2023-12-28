{
  system,
  username,
  pkgs,
  make-darwinConfiguration,
  ...
}:
make-darwinConfiguration {
  system = "${system}";
  inherit pkgs;
  modules = [
    {
      system.stateVersion = 4;
      system.defaults = {
        trackpad.TrackpadThreeFingerDrag = true;
        dock.autohide = true;
        finder = {
          AppleShowAllExtensions = true;
          _FXShowPosixPathInTitle = true;
        };
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          InitialKeyRepeat = 14;
          KeyRepeat = 1;
        };
      };
      nix.useDaemon = true;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
      documentation.enable = true;
      environment = {
        shells = with pkgs; [bash zsh];
        loginShell = pkgs.zsh;
        systemPackages = [pkgs.coreutils];
        systemPath = ["/opt/homebrew/bin"];
        pathsToLink = ["/Applications"];
      };
      fonts = {
        fontDir.enable = true; # only allow nix to control fonts
        fonts = [
          (pkgs.nerdfonts.override {
            fonts = [
              "FiraCode"
              "Hasklig"
              "DroidSansMono"
              "DejaVuSansMono"
              "iA-Writer"
              "JetBrainsMono"
              "Meslo"
              "SourceCodePro"
              "Inconsolata"
              "NerdFontsSymbolsOnly"
            ];
          })
        ];
      };
      homebrew = {
        # nix-darwin prevents cli use of brew, so to search use
        # the website at https://formulae.brew.sh/
        enable = true;
        caskArgs.no_quarantine = true;
        global.brewfile = true;
        masApps = {};
        casks = [
          "rectangle"
          "clipy"
          "emacs"
          "firefox"
          "google-chrome"
          "iterm2"
	  "obs"
          "spotify"
          "visual-studio-code"
	  "zoom"
        ];
      };
      security.pam.enableSudoTouchIdAuth = true;
    }
  ];
}
