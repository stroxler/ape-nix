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
      nix.useDaemon = true;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
      environment = {
        shells = with pkgs; [ bash zsh ];
        loginShell = pkgs.zsh;
        systemPackages = [ pkgs.coreutils ];
        systemPath = [ "/opt/homebrew/bin" ];
        pathsToLink = [ "/Applications" ];
      };
      fonts = {
        fontDir.enable = true;  # only allow nix to control fonts
        fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; }) ];
      };
      homebrew = {
        # nix-darwin prevents cli use of brew, so to search use
        # the website at https://formulae.brew.sh/
        enable = true;
        caskArgs.no_quarantine = true;
        global.brewfile = true;
        masApps = {};
        casks = [
          "amethyst"
          "clipy"
          "emacs"
          "firefox"
          "google-chrome"
          "iterm2"
          "spotify"
          "visual-studio-code"
        ];
      };
    }
  ];
}
