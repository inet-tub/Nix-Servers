{ pkgs, pkgs-unfree, config, lib, ... }:
let DATA_DIR = "/data/OnlyOffice"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/Documentserver 0750 109"
    "d ${DATA_DIR}/Documentserver/logs 0750 109"
    "d ${DATA_DIR}/Documentserver/data 0750 109"
    "d ${DATA_DIR}/Documentserver/lib 0750 109"
    "d ${DATA_DIR}/Documentserver/rabbitmq 0750 109"
    "d ${DATA_DIR}/Documentserver/redis 0750 109"
    "d ${DATA_DIR}/Documentserver/postgresql 0750 109"

    "d ${DATA_DIR}/Communityserver 0750 104"
    "d ${DATA_DIR}/Communityserver/logs 0750 104"
    "d ${DATA_DIR}/Communityserver/data 0750 104"

    "d ${DATA_DIR}/Controlpanel 0750 109"
    "d ${DATA_DIR}/Controlpanel/logs 0750 109"
    "d ${DATA_DIR}/Controlpanel/data 0750 109"
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

        environmentFiles = [ config.age.secrets.OnlyOffice-Documentserver.path ];

        volumes = [
          "${DATA_DIR}/Documentserver/logs:/var/log/onlyoffice"
          "${DATA_DIR}/Documentserver/data:/var/www/onlyoffice/Data"
          "${DATA_DIR}/Documentserver/lib:/var/lib/onlyoffice"
          "${DATA_DIR}/Documentserver/rabbitmq:/var/lib/rabbitmq"
          "${DATA_DIR}/Documentserver/redis:/var/lib/redis"
          "${DATA_DIR}/Documentserver/postgresql:/var/lib/postgresql/data"
        ];
      }
    )
    #    (
    #      import ./Container-Config/Oci-Container.nix {
    #        inherit config lib pkgs;
    #        name = "onlyoffice";
    #        image = "onlyoffice/communityserver:12.6.0.1900";
    #
    #        dataDir = DATA_DIR;
    #        containerNum = 6;
    #        containerSubNum = 2;
    #        containerPort = 80;
    #
    #        environment = {
    #          MYSQL_SERVER_HOST = "10.88.6.2";
    #          MYSQL_SERVER_PORT = "3306";
    #          MYSQL_SERVER_DB_NAME = "onlyoffice";
    #          MYSQL_SERVER_USER = "onlyoffice";
    #
    #          DOCUMENT_SERVER_PORT_80_TCP_ADDR = "10.88.6.1";
    #          CONTROL_PANEL_PORT_80_TCP = "80";
    #          CONTROL_PANEL_PORT_80_TCP_ADDR = "10.88.6.3";
    #        };
    #        environmentFiles = [ config.age.secrets.OnlyOffice-Communityserver.path ];
    #        mysqlEnvFile = config.age.secrets.OnlyOffice-Communityserver-Mysql.path;
    #
    #        volumes = [
    #          "${DATA_DIR}/Communityserver/logs:/var/log/onlyoffice"
    #          "${DATA_DIR}/Communityserver/data:/var/www/onlyoffice/Data"
    #        ];
    #      }
    #    )
    #    (
    #      import ./Container-Config/Oci-Container.nix {
    #        inherit config lib pkgs;
    #        name = "onlyoffice-controlpanel";
    #        image = "onlyoffice/controlpanel";
    #
    #        dataDir = DATA_DIR;
    #        containerNum = 6;
    #        containerSubNum = 3;
    #        containerPort = 80;
    #
    #        volumes = [
    #          "${DATA_DIR}/Controlpanel/logs:/var/log/onlyoffice"
    #          "${DATA_DIR}/Controlpanel/data:/var/www/onlyoffice/Data"
    #        ];
    #      }
    #    )
  ];
}
