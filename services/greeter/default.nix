{
  pkgs,
  username,
  ...
}: {
  services.greetd = {
    enable = true;
    restart = false;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --asterisks --greeting 'npuBeT nyncuk' --time --cmd Hyprland";
      user = username;
    };
  };
}
