{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/UrBackup"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "urbackup";
        image = "uroni/urbackup-server";
        containerPort = 55414;
        dataDir = DATA_DIR;
        containerNum = 4;

        additionalContainerConfig.extraOptions = [ "--device=/dev/zfs" ];
        environment = {
          PUID = "6004";
          PGID = "6004";
        };

        volumes = [
          "${DATA_DIR}/backups:${DATA_DIR}/backups"
          "${DATA_DIR}/urbackup:/var/urbackup"
          "${DATA_DIR}/www:/usr/share/urbackup"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 6004 6004"
    "d ${DATA_DIR}/backups/ 0750 6004 6004"
    "d ${DATA_DIR}/urbackup/ 0750 6004 6004"
    "d ${DATA_DIR}/www/ 0750 6004 6004"
  ];
}
