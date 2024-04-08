{
  pkgs,
  inputs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    zip
    unzip
    wget
    jq
    nmap
    dig
  ];

  home-manager.users.${username} = _: {
    home.packages = with pkgs; [
      # LXQt and Xfce packages
      lxqt.lxqt-policykit
      xdg-utils
      xfce.thunar
      xfce.tumbler

      # Audio and notification packages
      brightnessctl
      pulseaudio
      pavucontrol
      playerctl
      mako
      libnotify
      tofi

      # Screenshot and clipboard packages
      grim
      slurp
      wl-clipboard-rs
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast

      # Hypr-related packages
      hyprlock
      hypridle
      inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
      swww
      # hyprpaper

      # Applications
      google-chrome
      telegram-desktop
      vencord
      pgadmin4-desktopmode
      # todoist

      # Nix-related packages
      nil
      alejandra

      # Development packages
      nodejs_21
      python3

      # Miscellaneous packages
      nitch
    ];
  };

  programs = {
    git.enable = true;
    mtr.enable = true;
    ssh.startAgent = true;
    hyprland = {
      enable = true;
      # xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

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
}
