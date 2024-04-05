{
  pkgs,
  hostname,
  ...
}: {
  services = {
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
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };
}
