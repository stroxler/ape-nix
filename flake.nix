{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: let
    system = "aarch64-darwin";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    defaultPackage.${system} = inputs.home-manager.defaultPackage.${system};

  };
}
