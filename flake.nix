{
  description = "Nixos flake with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
 outputs = { self, nixpkgs, home-manager, ... }:
  {
    nixosConfigurations.snowline = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.schmoetyyy = import ./home/qhd.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
} 
