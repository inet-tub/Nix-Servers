{ config, modulesPath, ... }: {
  host = {
    name = "en-backup";
    id = "hostid_placeholder";
    bootDevices = [ "bootDevices_placeholder" ];

    zfsAutoSnapshot = {
      enable = true;
      weekly = 7;
      monthly = 120;
    };

    zfsArc = {
      minGB = 6;
      maxGB = 8;
      metaGB = 4;
    };

    networking = {
      ip = "130.149.152.130";
      interface = "enp2s0f0";

      adminIp = "192.168.201.130";
      adminInterface = "enp2s0f1";

      location = "en";
      networkRange = "ennet";
    };
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"

    "Backup/BackupPC.nix"
    "Backup/Restic.nix"
  ];
}
