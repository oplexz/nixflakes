{
  imports = [
    ./hardware-configuration.nix
  ];

  services.openvpn.servers.gbubr = {
    config = ''config /home/oplexz/ovpn/DIsakov.ovpn '';
    updateResolvConf = true;
  };

  # powerManagement.powertop.enable = true;
  # services.thermald.enable = true;
}
