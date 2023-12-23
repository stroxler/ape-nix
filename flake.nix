{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: let
    username = "stroxler";
  in
    inputs.nixpkgs.lib.foldl' inputs.nixpkgs.lib.recursiveUpdate {} [
      (let
        system = "aarch64-darwin";
        pkgs = import inputs.nixpkgs {inherit system;};
      in {
        defaultPackage.${system} = inputs.home-manager.defaultPackage.${system};
        homeConfigurations.macos-silicon = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ({pkgs, ...}: {
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
                };
              };
            })
          ];
        };
      })
      {
        defaultPackage.x86_64-darwin = inputs.home-manager.defaultPackage.x86_64-darwin;
      }
    ];
}
