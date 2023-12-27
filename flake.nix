{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    nixpkgsUnstable,
    home-manager,
    nix-darwin,
    ...
  }: let
    username = "stroxler";
  in
    nixpkgs.lib.foldl' nixpkgs.lib.recursiveUpdate {} [
      (let
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          inherit system;

          # needed mainly for Microsoft fonts
          config = {allowUnfree = true;};
        };
      in {
        # `nix build` able binaries, for bootstrapping
        packages.${system} = {
          home-manager = home-manager.defaultPackage.${system};
          darwin-rebuild = nix-darwin.packages.${system}.default;
          default = self.packages.${system}.home-manager;
        };
        # home manager configs. Build these with:
        #   nix build .#home-manger
        #   ./result/bin/home-manager --flake '.#[system]` switch
        homeConfigurations.${system} = import ./home.nix {
          inherit system;
          inherit username;
          inherit pkgs;
          make-homeConfiguration =
            home-manager.lib.homeManagerConfiguration;
        };
        darwinConfigurations.${system} = import ./darwin.nix {
          inherit system;
          inherit username;
          inherit pkgs;
          make-darwinConfiguration =
            nix-darwin.lib.darwinSystem;
        };
      })
      {
        packages.x86_64-darwin.default = home-manager.defaultPackage.x86_64-darwin;
      }
    ];
}
