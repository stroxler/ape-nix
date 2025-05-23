{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-u.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixd.url = "github:nix-community/nixd";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-u,
    nixd,
    home-manager,
    ...
  }: let
    username = "stroxler";
    pkgs-for-system = system: (nixpkgs-x:
      import nixpkgs-x {
        inherit system;

        # needed mainly for Microsoft fonts
        config = {allowUnfree = true;};
      });
    pkgs-for-system-u = system: nixpkgs
      import nixpkgs-u {
        inherit system;

        # needed mainly for Microsoft fonts
        config = {allowUnfree = true;};
      };
    home-manager-bin-and-config = system: let
      pkgs = pkgs-for-system system nixpkgs;
      pkgs-u = pkgs-for-system system nixpkgs-u;
    in {
      packages.${system} = {
        home-manager = home-manager.defaultPackage.${system};
        default = home-manager.defaultPackage.${system};
      };
      homeConfigurations.${system} = import ./home.nix {
        inherit system;
        inherit username;
        inherit pkgs;
        inherit pkgs-u;
        inherit nixd;
        make-homeConfiguration =
          home-manager.lib.homeManagerConfiguration;
      };
    };
    combine-configs = configs: nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate {} configs;
  in
    combine-configs [
      (home-manager-bin-and-config "x86_64-darwin")
      (home-manager-bin-and-config "aarch64-darwin")
      (home-manager-bin-and-config "x86_64-linux")
      (home-manager-bin-and-config "aarch64-linux")
    ];
}
