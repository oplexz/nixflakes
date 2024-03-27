{
  home-manager,
  pkgs,
  hostName,
  username,
  ...
}: {
  # region Core settings
  imports = [
    home-manager.nixosModules.default
    ./hosts/${hostName}
    ./users/${username}
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

  home-manager.users.${username} = _: {
    home.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;

    gtk.enable = true;
    gtk.cursorTheme.name = "Adwaita";
    gtk.cursorTheme.package = pkgs.gnome.adwaita-icon-theme;
    gtk.theme.name = "adw-gtk3-dark";
    gtk.theme.package = pkgs.adw-gtk3;

    home.file = {
      ".config/foot/foot.ini".source = ./config/foot/foot.ini;

      ".config/hypr/vol.sh" = {
        source = ./scripts/vol.sh;
        executable = true;
      };

      ".config/hypr/toggle_waybar.sh" = {
        source = ./scripts/toggle_waybar.sh;
        executable = true;
      };

      ".config/hypr/hyprland.conf".source = ./config/hypr/desktop/hyprland.conf;
      ".config/mako/config".source = ./config/mako/config;
      ".config/tofi/config".source = ./config/tofi/config;
      ".config/waybar/config.jsonc".source = ./config/waybar/desktop/config.jsonc;
      ".config/waybar/style.css".source = ./config/waybar/desktop/style.css;
    };

    programs = {
      vscode = {
        enable = true;
        package = pkgs.vscode.fhs;
      };
      foot.enable = true;
      # alacritty.enable = true;
      btop.enable = true;
      htop.enable = true;
      # gh.enable = true;
      # ripgrep.enable = true;
      waybar.enable = true;
      # direnv = {
      #   enable = true;
      #   nix-direnv.enable = true;
      # };
    };
    home.packages = with pkgs; [
      # Core
      lxqt.lxqt-policykit
      xdg-utils
      xfce.thunar
      xfce.tumbler
      unzip
      wget

      # Utils
      brightnessctl
      pulseaudio
      pavucontrol
      playerctl
      wl-clipboard
      mako
      libnotify
      tofi
      grim
      slurp
      nitch
      hyprlock
      hypridle
      hyprpaper
      # hyprpicker
      # swww

      # Apps
      google-chrome
      telegram-desktop
      # todoist

      # Dev
      pgadmin4-desktopmode
      nil
      alejandra
    ];
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    git.enable = true;
    mtr.enable = true;
    ssh.startAgent = true;
    hyprland.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
    bash = {
      interactiveShellInit = ''
        nitch
      '';
      shellAliases = {
        cp = "cp -ia";
        ls = "ls -la";
        mv = "mv -i";

        sw = "sudo nixos-rebuild switch --flake .";
      };
    };
    zsh.enable = true;

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        scan_timeout = 10;
        format = "$all";
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
          vimcmd_symbol = "[<](bold green)";
        };

        git_commit = {tag_symbol = " tag ";};
        git_status = {
          ahead = ">";
          behind = "<";
          diverged = "<>";
          renamed = "r";
          deleted = "x";
        };
        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow)";
        };
        aws = {symbol = "aws ";};
        azure = {symbol = "az ";};
        bun = {symbol = "bun ";};

        cmake = {symbol = "cmake ";};
        deno = {symbol = "deno ";};
        directory = {read_only = " ro";};
        docker_context = {symbol = "docker ";};
        git_branch = {symbol = "git ";};
        golang = {symbol = "go ";};
        hostname = {
          ssh_only = false;
          format = " on [$hostname](bold red)\n";
          disabled = false;
        };
        lua = {symbol = "lua ";};
        nodejs = {symbol = "nodejs ";};
        memory_usage = {symbol = "memory ";};
        nim = {symbol = "nim ";};
        nix_shell = {symbol = "nix ";};
        os.symbols = {
          Alpaquita = "alq ";
          Alpine = "alp ";
          Amazon = "amz ";
          Android = "andr ";
          Arch = "rch ";
          Artix = "atx ";
          CentOS = "cent ";
          Debian = "deb ";
          DragonFly = "dfbsd ";
          Emscripten = "emsc ";
          EndeavourOS = "ndev ";
          Fedora = "fed ";
          FreeBSD = "fbsd ";
          Garuda = "garu ";
          Gentoo = "gent ";
          HardenedBSD = "hbsd ";
          Illumos = "lum ";
          Linux = "lnx ";
          Mabox = "mbox ";
          Macos = "mac ";
          Manjaro = "mjo ";
          Mariner = "mrn ";
          MidnightBSD = "mid ";
          Mint = "mint ";
          NetBSD = "nbsd ";
          NixOS = "nix ";
          OpenBSD = "obsd ";
          OpenCloudOS = "ocos ";
          openEuler = "oeul ";
          openSUSE = "osuse ";
          OracleLinux = "orac ";
          Pop = "pop ";
          Raspbian = "rasp ";
          Redhat = "rhl ";
          RedHatEnterprise = "rhel ";
          Redox = "redox ";
          Solus = "sol ";
          SUSE = "suse ";
          Ubuntu = "ubnt ";
          Unknown = "unk ";
          Windows = "win ";
        };
        package = {symbol = "pkg ";};
        purescript = {symbol = "purs ";};
        python = {symbol = "py ";};
        rust = {symbol = "rs ";};
        status = {symbol = "[x](bold red) ";};
        sudo = {symbol = "sudo ";};
        terraform = {symbol = "terraform ";};
        username = {
          style_user = "green bold";
          style_root = "red bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = true;
        };
        zig = {symbol = "zig ";};
      };
    };
  };

  hardware.bluetooth.enable = true;

  services = {
    xserver = {
      xkb.layout = "us,ru";
      xkb.variant = "";
    };

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
    inherit hostName;
  };

  security.rtkit.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  environment = {
    sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  security.pam.services.login.enableGnomeKeyring = true;

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
