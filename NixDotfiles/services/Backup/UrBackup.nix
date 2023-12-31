{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/UrBackup"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "urbackup";
        image = "uroni/urbackup-server";
        containerIP = "10.88.4.1";
        containerPort = 55414;

        additionalContainerConfig.extraOptions = [ "--device=/dev/zfs" ];
        environment = {
          PUID = "6004";
          PGID = "6004";
        };

        volumes = [
          "${DATA_DIR}/backups:/backups"
          "${DATA_DIR}/urbackup:/var/urbackup"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 6004 6004"
    "d ${DATA_DIR}/backups/ 0750 6004 6004"
    "d ${DATA_DIR}/urbackup/ 0750 6004 6004"
  ];
}
