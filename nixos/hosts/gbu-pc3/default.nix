{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    openvpn3
    cifs-utils
  ];

  services = {
    openvpn.servers.gbubr = {
      config = ''config /home/oplexz/ovpn/DIsakov.ovpn '';
      updateResolvConf = true;
    };

    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # region krb5

  security.krb5 = {
    enable = true;
    settings = {
      libdefaults = {
        default_realm = "GBUBR.LOCAL";
        dns_lookup_realm = true;
        dns_lookup_kdc = true;
      };
    };
  };

  systemd.services.kinit = {
    description = "Kerberos ticket initialization";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.krb5}/bin/kinit -k -t /home/oplexz/secrets/d.isakov.keytab d.isakov";
      RemainAfterExit = "yes";
    };
  };

  # endregion

  fileSystems."/mnt/gbu1c" = {
    device = "//gbu1c/ГБУ";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/home/oplexz/secrets/smb-secrets"];
  };

  # systemd.services.mount-gbu1c = {
  #   description = "Mount GBU1C";
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.cifs-utils}/bin/mount -t cifs -o vers=3.0,user=d.isakov@GBUBR.LOCAL,sec=krb5 //gbu1c/гбу /mnt/gbu1c";
  #     ExecStop = "${pkgs.cifs-utils}/bin/umount /mnt/gbu1c";
  #     RemainAfterExit = "yes";
  #   };
  # };

  # powerManagement.powertop.enable = true;
  # services.thermald.enable = true;
}
