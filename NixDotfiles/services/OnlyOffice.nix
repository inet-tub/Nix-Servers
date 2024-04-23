{ pkgs, pkgs-unfree, config, lib, ... }:
let DATA_DIR = "/data/OnlyOffice"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 109"
    "d ${DATA_DIR}/onlyoffice 0750 109"
    "d ${DATA_DIR}/logs 0750 109"
  ];

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "onlyoffice-documentserver";
        image = "onlyoffice/documentserver";

        dataDir = DATA_DIR;
        containerNum = 6;
        containerPort = 80;

        environmentFiles = [ config.age.secrets.OnlyOffice.path ];

        volumes = [
          "${DATA_DIR}/logs:/var/log/onlyoffice"
          "${DATA_DIR}/onlyoffice:/var/www/onlyoffice/Data"
        ];
      }
    )
  ];
}
