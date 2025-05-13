{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    neovim-nightly-overlay,
    ...
  }: let
    username = "stroxler";
    pkgs-for-system = system:
      import nixpkgs {
        inherit system;

        # needed mainly for Microsoft fonts
        config = {allowUnfree = true;};
      };
    home-manager-bin-and-config = system: let
      pkgs = pkgs-for-system system;
    in {
      packages.${system} = {
        home-manager = home-manager.defaultPackage.${system};
        default = home-manager.defaultPackage.${system};
      };
      homeConfigurations.${system} = import ./home.nix {
        inherit system;
        inherit username;
        inherit pkgs;
        inherit neovim-nightly-overlay;
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
