{
  home-manager,
  username,
  ...
}: {
  imports = [
    home-manager.nixosModules.default
    ./users/${username}
  ];

  home-manager.useGlobalPkgs = true;
}
