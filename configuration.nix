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
    ./home-manager/users/${username}
    ./programs
    ./l18n
  ];

  nix = {
    # TODO: What does this do?
    # nixPath = ["nixpkgs=/run/current-system/nixpkgs"];
    settings.experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;

  system = {
    # TODO: What does this do?
    # extraSystemBuilderCmds = ''
    #   ln -sv ${pkgs.path} $out/nixpkgs
    # '';
    stateVersion = "23.11";
  };
  # endregion

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  security = {
    rtkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;
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

  hardware.bluetooth.enable = true;

  services = {
    blueman.enable = true;

    gnome = {gnome-keyring.enable = true;};

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    greetd = {
      enable = true;
      restart = false;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --asterisks --greeting 'npuBeT nyncuk' --time --cmd Hyprland";
          user = username;
        };
      };
    };

    resolved = {
      enable = true;
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    hostName = hostname;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;

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
