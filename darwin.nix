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
      homebrew = {
        # nix-darwin prevents cli use of brew, so to search use
        # the website at https://formulae.brew.sh/
        enable = true;
        caskArgs.no_quarantine = true;
        global.brewfile = true;
        masApps = {};
        casks = [
          "clipy"
          "emacs"
          "firefox"
          "google-chrome"
          "iterm2"
          "rectangle"
          "spotify"
          "visual-studio-code"
        ];
      };
    }
  ];
}
