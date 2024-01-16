{ pkgs, pkgs-unfree, config, lib, ... }:
let DATA_DIR = "/data/OnlyOffice"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 onlyoffice"
    "d ${DATA_DIR}/onlyoffice 0755 onlyoffice"
    "d ${DATA_DIR}/postgresql 0755 postgres"
    "d ${DATA_DIR}/rabbitmq 0755 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "onlyoffice";
        subdomain = "onlyoffice-documentserver";
        containerIP = "192.168.7.111";
        containerPort = 8000;
        postgresqlName = "onlyoffice";

        imports = [ ../users/services/onlyoffice.nix ];
        bindMounts = {
          "/var/lib/onlyoffice/" = { hostPath = "${DATA_DIR}/onlyoffice"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "/var/lib/rabbitmq/" = { hostPath = "${DATA_DIR}/rabbitmq"; isReadOnly = false; };
          "${config.age.secrets.OnlyOffice.path}".hostPath = config.age.secrets.OnlyOffice.path;
        };

        cfg = {
          services.onlyoffice = {
            package = pkgs-unfree.onlyoffice-documentserver;
            enable = true;
            hostname = "onlyoffice.${config.domainName}";
            jwtSecretFile = config.age.secrets.OnlyOffice.path;
          };
        };
      }
    )
  ];
}
