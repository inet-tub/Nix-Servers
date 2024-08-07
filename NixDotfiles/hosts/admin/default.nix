{ config, modulesPath, ... }: {
  host = {
    name = "admin";
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
      ip = "130.149.152.137";
      interface = "eno1";

      adminIp = "192.168.201.137";
      adminInterface = "eno2";

      location = "en";
      networkRange = "ennet";
    };
  };

  monitoredServices = {
    netbox = true;
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"
    "Backup/Restic-Client.nix"
    "Admin/NetBox.nix"
    "Admin/YouTrack.nix"
    "Authentication/IPA-Client.nix"
  ];
}
