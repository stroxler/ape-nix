{
  description = "stroxler system setup with nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , ...
    }:
    let
      username = "stroxler";
      pkgs-for-system = system: import nixpkgs {
        inherit system;

        # needed mainly for Microsoft fonts
        config = { allowUnfree = true; };
      };
      make-packages = system:
        let pkgs = pkgs-for-system system; in {
          packages.${system} = {
            darwin-rebuild = nix-darwin.packages.${system}.default;
            default = self.${system}.packages.darwin-rebuild;
          };
        };
      make-darwin-configuration = system: owner:
        if (system != "x86_64-darwin" && system != "aarch64-darwin")
        then abort "nix-darwin can only be used on darwin systems"
        else
          let configuration-name = "${system}--${owner}"
          let pkgs = pkgs-for-system system; in {
            darwinConfigurations.${configuration-name} = import ./darwin.nix {
              inherit system;
              inherit owner;
              inherit username;
              inherit pkgs;
              make-darwinConfiguration =
                nix-darwin.lib.darwinSystem;
            };
          };
      combine-configs = configs: nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate { } configs;
    in
    combine-configs [
      (make-packages "x86_64-darwin")
      (make-packages "aarch64-darwin")
      (make-darwin-configuration "x86_64-darwin" "me")
      (make-darwin-configuration "aarch64-darwin" "me")
      (make-darwin-configuration "aarch64-darwin" "work")
    ];
}
