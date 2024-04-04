{hostname, ...}: {
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
}
