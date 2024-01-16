{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/NetBox"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "netbox";
        image = "linuxserver/netbox:latest";

        subdomain = "netbox";
        containerIP = "10.88.5.1";
        containerPort = 8000;
        environment = {
          PUID = "6050";
          PGID = "6050";
          SUPERUSER_EMAIL = "admins@inet.tu-berlin.de";
          ALLOWED_HOST = "netbox.inet.tu-berlin.de";

          DB_USER = "netbox";
          DB_HOST = "10.88.5.2";

          REDIS_HOST = "10.88.5.3";

        };
        environmentFiles = [ config.age.secrets.NetBox.path ];

        volumes = [
          "${DATA_DIR}/netbox:/config"
        ];
      }
    )

    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "netbox-postgres";
        image = "postgres:15-alpine";

        containerIP = "10.88.5.2";
        containerPort = 5432;
        makeNginxConfig = false;

        environment = {
          POSTGRES_DB = "netbox";
          POSTGRES_USER = "netbox";
        };
        environmentFiles = [ config.age.secrets.NetBox.path ];

        volumes =
        [
          "${DATA_DIR}/postgresql:/var/lib/postgresql/data"
        ];
      }
    )

    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "netbox-redis";
        image = "redis:7.2.4-alpine";

        containerIP = "10.88.5.3";
        containerPort = 6379;
        makeNginxConfig = false;

        volumes =
        [
          "${DATA_DIR}/redis:/data"
        ];
      }
    )


  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 6050 6050"
    "d ${DATA_DIR}/netbox/ 0750 6050 6050"
    "d ${DATA_DIR}/postgresql/ 0750 70 70"
    "d ${DATA_DIR}/redis/ 0750 999 999"
  ];
}
