{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    nixosConfigurations = {
      gbu-pc3 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          username = "oplexz";
          hostname = "gbu-pc3";
          system = "x86_64-linux";
          inherit inputs;
        };
        modules = [
          ./configuration.nix
        ];
      };
      aeschylus = nixpkgs.lib.nixosSystem {
        specialArgs = {
          username = "oplexz";
          hostname = "aeschylus";
          system = "x86_64-linux";
          inherit inputs;
        };
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
