{ config, modulesPath, ... }: {
  host = {
    name = "en-observertory";
    id = "hostid_placeholder";
    bootDevices = [ "bootDevices_placeholder" ];

    zfsAutoSnapshot = {
      enable = true;
      weekly = 7;
      monthly = 120;
    };

    zfsArc = {
      minGB = 8;
      maxGB = 48;
      metaGB = 12;
    };

    networking = {
      ip = "130.149.152.135";
      interface = "eno1";

      adminIp = "192.168.201.135";
      adminInterface = "eno2";

      location = "en";
      networkRange = "ennet";
    };

  };

  monitoredServices = {
    prometheus = true;
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"
    "Backup/Restic-Client.nix"
    "Monitoring/Prometheus.nix"
    "Monitoring/Grafana.nix"
  ];
}
