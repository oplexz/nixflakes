{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ attrs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    nixosConfigurations = {
      gbu-pc3 = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            username = "oplexz";
            hostName = "gbu-pc3";
            system = "x86_64-linux";
          }
          // attrs;
        modules = [
          ./configuration.nix
        ];
      };
      aeschylus = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            username = "oplexz";
            hostName = "aeschylus";
            system = "x86_64-linux";
          }
          // attrs;
        modules = [
          ./configuration.nix
        ];
      };
    };

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default =
        pkgs.mkShell {buildInputs = with pkgs; [nixfmt statix];};
    });
  };
}
