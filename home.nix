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
        file = {
          # Note: .inputrc only affects readline using tools, which includes
          # bash but not zsh (bindkey directives control this in zsh).
          ".inputrc".text = ''
            "\e[A": history-search-backward
            "\e[B": history-search-forward
          '';
        };
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
        zsh = {
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
            bindkey '^[[A' history-substring-search-up # or '\eOA'
            bindkey '^[[B' history-substring-search-down # or '\eOB'
          '';
        };
      };
    }
  ];
}
