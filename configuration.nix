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
      # ".config/waybar/config.jsonc".source = ./config/waybar/desktop/config.jsonc;
      # ".config/waybar/style.css".source = ./config/waybar/desktop/style.css;
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
      # direnv = {
      #   enable = true;
      #   nix-direnv.enable = true;
      # };
    };
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          height = 45;
          modules-left = ["custom/nix" "cpu" "memory" "disk"];
          modules-center = ["hyprland/workspaces"];
          modules-right = ["pulseaudio" "backlight" "network" "battery" "clock"];
          "custom/nix" = {
            format = " ";
            tooltip = false;
            on-click = "/run/current-system/sw/bin/wofi --show drun";
          };
          "hyprland/workspaces" = {
            format = "{name} {icon}";
            tooltip = false;
            all-outputs = true;
            format-icons = {
              active = "";
              default = "";
            };
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";
            on-click = "activate";
          };
          cpu = {
            format = "󰻠 {usage}%";
            tooltip = true;
            on-click = "foot sh -c 'btop'";
            interval = 2;
          };
          memory = {
            format = " {}%";
            tooltip = true;
            on-click = "foot sh -c 'btop'";
            interval = 2;
          };
          temperature = {
            critical-threshold = 40;
            format-critical = "{icon} {temperatureC}°C";
            format = "{icon} {temperatureC}°C";
            format-icons = ["" "" ""];
            interval = 2;
          };
          disk = {
            format = " {percentage_used}% ({free})";
            tooltip = true;
            interval = 2;
            on-click = "kitty sh -c 'ranger'";
          };
          clock = {
            format = "  {:%d <small>%a</small> %H:%M}";
            format-alt = "  {:%A %B %d %Y (%V) | %r}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            calendar-weeks-pos = "right";
            today-format = "<span color='#f38ba8'><b><u>{}</u></b></span>";
            format-calendar = "<span color='#f2cdcd'><b>{}</b></span>";
            format-calendar-weeks = "<span color='#94e2d5'><b>W{:%U}</b></span>";
            format-calendar-weekdays = "<span color='#f9e2af'><b>{}</b></span>";
            interval = 60;
          };
          backlight = {
            device = "intel_backlight";
            format = "<span color='#2da14c'>{icon}</span> {percent}%";
            format-icons = ["" "" "" "" "" "" "" "" ""];
            on-scroll-up = "brightnessctl set +2%";
            on-scroll-down = "brightnessctl set 2%-";
            interval = 2;
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-bluetooth-muted = "󰗿";
            format-muted = "";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "󰋋";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = " ";
              default = ["" "" " "];
            };
            on-click = "pavucontrol";
          };
          bluetooth = {
            format = "<span color='#0056A3'></span> {status}";
            format-disabled = "";
            format-connected = "<span color='#0056A3'></span> {num_connections}";
            tooltip-format = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}   {device_address}";
          };
          network = {
            interface = "wlp*";
            format = "󰱓 {bandwidthTotalBytes}";
            format-disconnected = "{icon} No Internet";
            format-linked = "󰅛 {ifname} (No IP)";
            format-alt = "󰛶 {bandwidthUpBytes} | 󰛴 {bandwidthDownBytes}";
            tooltip-format = "{ifname}: {ipaddr}/{cidr} Gateway: {gwaddr}";
            tooltip-format-wifi = "{icon} {essid} ({signalStrength}%)";
            tooltip-format-ethernet = "{icon} {ipaddr}/{cidr}";
            tooltip-format-disconnected = "{icon} Disconnected";
            format-icons = {
              ethernet = "󰈀";
              disconnected = "⚠";
              wifi = ["󰖪" ""];
            };
            interval = 2;
          };
          battery = {
            states = {
              good = 100;
              warning = 30;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{icon} {time}";
            format-full = " {capacity}%";
            format-icons = [" " " " " " " " " " " "];
            interval = 2;
          };
          "custom/power" = {
            format = "{}";
            exec = "echo '{\"text\":\"⏻\";\"tooltip\" =\"Power\"}'";
            return-type = "json";
            on-click = "sudo ~/.config/wlogout/launch.sh";
          };
        };
      };
      style = ''
        * {
              font-family: "M+1Code Nerd Font";
              font-size: 16px;
              min-height: 30px;
          }

          window#waybar {
              background: transparent;
          }

          #workspaces {
              background-color: transparent;
              color: #0d74bd;
              margin-top: 15px;
              margin-right: 15px;
              padding-top: 1px;
              padding-left: 10px;
              padding-right: 10px;
          }

          #custom-nix {
              background-color: transparent;
              color: #0a60ab;
              margin-top: 15px;
              margin-right: 15px;
              padding-top: 1px;
              padding-left: 10px;
              padding-right: 10px;
          }

          #custom-nix {
              font-size: 20px;
              margin-left: 15px;
              color: #0a60ab;
          }

          #workspaces button {
              background: transparent;
              color: #0d74bd;
          }

          #cpu,
          #memory,
          #temperature,
          #disk,
          #clock,
          #backlight,
          #pulseaudio,
          #bluetooth,
          #network,
          #battery,
          #custom-power {
              background-color: transparent;
              color: #00ba69;
              margin-top: 15px;
              padding-left: 10px;
              padding-right: 10px;
              margin-right: 15px;
          }

          #cpu {
              color: #ffd700;
          }

          #memory {
              color: #008000;
          }

          #disk {
              color: #a8a8a8;
          }

          #backlight,
          #bluetooth {
              color: #0056a3;
              padding-right: 5px;
              margin-right: 0;
          }

          #network {
              color: #10a140;
              padding-left: 5px;
          }

          #pulseaudio {
              color: #ba23d9;
              padding-left: 5px;
          }

          #clock {
              color: #00ba69;
          }
      '';
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
      nodejs_21
      python3
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
