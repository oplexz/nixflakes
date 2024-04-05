{
  home-manager,
  pkgs,
  username,
  ...
}: {
  imports = [
    home-manager.nixosModules.default
  ];
  home-manager.users.${username} = _: {
    home.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;

    gtk.enable = true;
    gtk.cursorTheme.name = "Adwaita";
    gtk.cursorTheme.package = pkgs.gnome.adwaita-icon-theme;
    gtk.theme.name = "adw-gtk3-dark";
    gtk.theme.package = pkgs.adw-gtk3;

    home.file = {
      ".config/foot/foot.ini".source = ../../../config/foot/foot.ini;

      ".config/hypr/vol.sh" = {
        source = ../../../scripts/vol.sh;
        executable = true;
      };

      ".config/hypr/toggle_waybar.sh" = {
        source = ../../../scripts/toggle_waybar.sh;
        executable = true;
      };

      ".config/mako/config".source = ../../../config/mako/config;
      ".config/tofi/config".source = ../../../config/tofi/config;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
        # ...
      ];

      settings = {
        # https://wiki.hyprland.org/Configuring/Monitors/
        monitor = ",preferred,auto,auto";

        # region https://wiki.hyprland.org/Configuring/Keywords/
        "$mod" = "SUPER";
        "$terminal" = "foot";
        "$fileManager" = "thunar";
        # $menu = wofi --show drun
        "$menu" = "tofi-run | xargs hyprctl dispatch exec";
        # $screenshot = grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png
        "$screenshot" = "slurp | grim -g - - | wl-copy";

        exec-once = "hyprpaper & mako & lxqt-policykit-agent & dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
        # endregion

        # https://wiki.hyprland.org/Configuring/XWayland/
        xwayland = {
          force_zero_scaling = true;
        };

        # https://wiki.hyprland.org/Configuring/Environment-variables/
        env = [
          # "GDK_SCALE,2"
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
          # "WLR_DRM_NO_ATOMIC,1"
        ];

        # region https://wiki.hyprland.org/Configuring/Variables/
        input = {
          kb_layout = "us,ru";
          kb_options = "grp:caps_toggle"; # "grp:win_space_toggle"

          follow_mouse = 1;

          touchpad = {
            natural_scroll = false;
            # middle_button_emulation = "true";
            # tap-and-drag = "true";
          };

          sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
        };

        # https://wiki.hyprland.org/Configuring/Binds/
        bind = [
          "$mod, Q, exec, $terminal"
          "$mod, C, killactive, "
          "$mod, F, fullscreen,"
          "$mod, a, exec, pavucontrol"
          # "$mod, v, exec, code"
          "$mod, M, exit, "
          "$mod, E, exec, $fileManager"
          "$mod, D, togglefloating, "
          "$mod, R, exec, $menu"
          "$mod, P, pseudo, # dwindle"
          "$mod, J, togglesplit, # dwindle"
          "$mod, L, exec, hyprlock"
          "$mod, O, exec, bash -i ~/.config/hypr/toggle_waybar.sh"
          ", Print, exec, $screenshot"

          ",XF86AudioMute, exec, ~/.config/hypr/vol.sh --mute"
          ",XF86AudioLowerVolume, exec, ~/.config/hypr/vol.sh --down"
          ",XF86AudioRaiseVolume, exec, ~/.config/hypr/vol.sh --up"

          ",xF86AudioPlay, exec, playerctl play-pause"
          ",xF86AudioNext, exec, playerctl next"
          ",xF86AudioPrev, exec, playerctl previous"

          # Move focus with mainMod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move windows with mainMod + Shift + Arrow keys
          "$mod shift, left, movewindow, l"
          "$mod shift, right, movewindow, r"
          "$mod shift, up, movewindow, u"
          "$mod shift, down, movewindow, d"

          # Switch workspaces with mainMod + [0-9]
          "$mod, 1, workspace, 1"
          "$mod, 1, exec,$w1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Example special workspace (scratchpad)
          # "$mod, S, togglespecialworkspace, magic"
          # "$mod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces with mainMod + scroll
          # "$mod, mouse_down, workspace, e+1"
          # "$mod, mouse_up, workspace, e-1"
        ];

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          layout = "dwindle";
          cursor_inactive_timeout = 15;

          allow_tearing = false;
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            size = 3;
            # passes = 3;
            new_optimizations = true;
            # xray = true;
          };

          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };

        animations = {
          enabled = true;

          bezier = [
            "snappyBezier, 0.4, 0.0, 0.2, 1.0"
            "smoothBezier, 0.25, 0.1, 0.25, 1.0"
          ];

          animation = [
            "windows, 1, 7, smoothBezier, slide"
            "windowsOut, 1, 7, snappyBezier, slide"
            "border, 1, 10, snappyBezier"
            # "borderangle, 1, 100, smoothBezier, loop"
            "fade, 1, 7, smoothBezier"
            "workspaces, 1, 6, smoothBezier, slidefadevert 20%"
          ];
        };

        gestures = {
          workspace_swipe = "off";
        };

        misc = {
          disable_hyprland_logo = "true";
          disable_splash_rendering = "true";

          enable_swallow = "true";
          swallow_regex = "^(foot)$";
        };
        # endregion

        # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
        dwindle = {
          pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # you probably want this
        };

        # https://wiki.hyprland.org/Configuring/Master-Layout/
        master = {
          new_is_master = "true";
        };

        # https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs
        # device = {
        #     name = epic-mouse-v1
        #     sensitivity = -0.5
        # }

        # https://wiki.hyprland.org/Configuring/Window-Rules/
        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

        # Custom workspaces
        # $wA = Alpha
        # workspace=name:$wA,monitor:eDP-1,default:true
        # bind = "$mod, 3, workspace, name:$wA"
      };
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
      # hyprpaper
      # hyprpicker
      swww

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
}
