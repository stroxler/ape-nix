{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        homeConfigurations.${system} = import ./home.nix {
          inherit system;
          inherit username;
          inherit pkgs;
          make-homeConfiguration =
            inputs.home-manager.lib.homeManagerConfiguration;
        };
      })
      {
        defaultPackage.x86_64-darwin = inputs.home-manager.defaultPackage.x86_64-darwin;
      }
    ];
}
