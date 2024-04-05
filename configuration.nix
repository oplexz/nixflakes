{
  pkgs,
  hostname,
  username,
  ...
}: {
  # region Core settings
  imports = [
    ./nixos/hosts/${hostname}
    ./nixos/users/${username}
    ./home-manager
    ./programs
    ./l18n
    ./services
  ];

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = "23.11";
  };
  # endregion

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services = {
    # blueman.enable = true;
  };
  # hardware.bluetooth.enable = true;
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      debug = true;
      extraConfig = ''
        /* Log authorization checks. */
        polkit.addRule(function(action, subject) {
          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
        });
      '';
    };
  };

  fonts = {
    packages = with pkgs; [
      monaspace
      inconsolata
      # noto-fonts
      noto-fonts-lgc-plus
      # noto-fonts-cjk
      # noto-fonts-emoji
      nerdfonts
    ];
    fontconfig.defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Noto Sans Mono" "Monaspace Neon"];
      emoji = ["Noto Color Emoji"];
    };
  };

  environment = {
    sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = ["xdph" "gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.portal.FileChooser" = ["xdg-desktop-portal-gtk"];
      };
    };
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };
}
