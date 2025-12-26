{
  description = "NixOS configurations for Rayyan's Router";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko?ref=v1.11.0";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in
    {
      # expose disko as an app for `nix run .#disko`
      apps.${system}.disko = {
        type = "app";
        program = lib.getExe disko.packages.${system}.disko;
      };

      nixosConfigurations = {
        edge-router = lib.nixosSystem {
          inherit system;
          modules = [
            ./machines/edge-router
            disko.nixosModules.disko
            ./machines/edge-router/disko.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
      };
    };
}
