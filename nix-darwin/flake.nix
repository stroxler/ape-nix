{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  }: let
    username = "stroxler";
    pkgs-for-system = system:
      import nixpkgs {
        inherit system;

        # needed mainly for Microsoft fonts
        config = {allowUnfree = true;};
      };
    nix-darwin-bin = system:
      if (system != "x86_64-darwin" && system != "aarch64-darwin")
      then abort "nix-darwin is only usable on darwin systems"
      else let
        pkgs = pkgs-for-system system;
      in {
        packages.${system}.default = nix-darwin.packages.${system}.default;
      };
    combine-configs = configs: nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate {} configs;
    nix-darwin-config = system: owner: let
      pkgs = pkgs-for-system system;
      configuration-name = "${system}--${owner}";
    in {
      darwinConfigurations.${configuration-name} = nix-darwin.lib.darwinSystem {
        inherit system;
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
                KeyRepeat = 5;
              };
            };
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';
            documentation.enable = true;
            environment = {
              shells = with pkgs; [zsh bash];
              systemPackages = [pkgs.coreutils];
              systemPath = ["/opt/homebrew/bin"];
              pathsToLink = ["/Applications"];
            };
            fonts = {
              packages = [
                pkgs.nerd-fonts.fira-code
                pkgs.nerd-fonts.hasklug
                pkgs.nerd-fonts.droid-sans-mono
                pkgs.nerd-fonts.dejavu-sans-mono
                pkgs.nerd-fonts.jetbrains-mono
                pkgs.nerd-fonts.inconsolata
              ];
            };
            homebrew = {
              # nix-darwin prevents cli use of brew, so to search use
              # the website at https://formulae.brew.sh/
              enable = true;
              caskArgs.no_quarantine = true;
              global.brewfile = true;
              masApps = {};
              casks =
                [
                  "rectangle"
                  "clipy"
                ];
            };
            security.pam.services.sudo_local.touchIdAuth = true;
          }
        ];
      };
    };
  in
    combine-configs [
      (nix-darwin-bin "x86_64-darwin")
      (nix-darwin-bin "aarch64-darwin")
      (nix-darwin-config "x86_64-darwin" "me")
      (nix-darwin-config "aarch64-darwin" "me")
      (nix-darwin-config "aarch64-darwin" "work")
    ];
}
