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
    {
      home = {
        stateVersion = "23.11";
        username = "${username}";
        homeDirectory = "/Users/${username}";
        packages = [
          pkgs.cowsay
        ];
      };
      programs = {
        home-manager = {
          enable = true;
        };
        git = {
          enable = true;
          userName = "Steven Troxler";
          userEmail = "steven.troxler@gmail.com";
          aliases = {
            check = "checkout";
          };
          ignores = [
            "result"
          ];
        };
      };
    }
  ];
}
