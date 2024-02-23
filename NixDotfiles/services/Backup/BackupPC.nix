{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/BackupPC"; in
{

  # TODO: AutoUpdate
  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "backuppc";
        image = "adferrand/backuppc:4";
        dataDir = DATA_DIR;
        containerNum = 3;

        containerPort = 8080;
        additionalContainerConfig.extraOptions = [ "--cap-add=NET_ADMIN" "--privileged" ];

        environmentFiles = [ config.age.secrets.BackupPC.path ];
        environment = {
          BACKUPPC_UUID = "6003";
          BACKUPPC_GUID = "6003";
        };

        volumes = [
          "${DATA_DIR}/config/:/etc/backuppc"
          "${DATA_DIR}/user/:/home/backuppc"
          "${DATA_DIR}/backups/:/data/backuppc"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 6003 6003"
    "d ${DATA_DIR}/config/ 0750 6003 6003"
    "d ${DATA_DIR}/user/ 0750 6003 6003"
    "d ${DATA_DIR}/backups/ 0750 6003 6003"
  ];
}
