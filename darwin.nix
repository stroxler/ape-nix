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
        enable = true;
        caskArgs.no_quarantine = true;
        global.brewfile = true;
        masApps = {};
        casks = [
          "clipy"
          "emacs"
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
