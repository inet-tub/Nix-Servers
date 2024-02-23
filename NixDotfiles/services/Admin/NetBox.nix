{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/NetBox"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "netbox";
        image = "linuxserver/netbox:latest";
        dataDir = DATA_DIR;

        subdomain = "netbox";
        containerNum = 5;
        containerPort = 8000;

        environmentFiles = [ config.age.secrets.NetBox_Env.path ];
        postgresEnvFile = config.age.secrets.NetBox_Postgres.path;
        redisEnvFile = config.age.secrets.NetBox_Redis.path;

        environment = {
          PUID = "6050";
          PGID = "6050";
          SUPERUSER_EMAIL = "admins@inet.tu-berlin.de";
          ALLOWED_HOST = "admin-netbox.inet.tu-berlin.de";

          DB_USER = "postgres";
          DB_HOST = "127.0.0.1";
          REDIS_HOST = "127.0.0.1";
        };

        volumes = [
          "${DATA_DIR}/netbox:/config"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/netbox/ 0750 6050 6050"
  ];
}
