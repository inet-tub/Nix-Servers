{ config, modulesPath, ... }: {
  host = {
    name = "en-backup";
    id = "abcd1234";
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
      location = "en";
      networkRange = "ennet";
      interface = "enp2s0f0";
    };
  };

  monitoredServices = {
    nginx.enable = true;
    smartctl.enable = true;
    zfs.enable = true;
    urbackup.enable = true;
  };

  services.urbackup-client.enable = false;

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"

    "Backup/UrBackup.nix"
    "Backup/Borg.nix"
    "Backup/Restic.nix"
    "Backup/Rsnapshot.nix"
    "Backup/BackupPC.nix"
  ];
}
