{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/NetBox"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 netbox"
    "d ${DATA_DIR}/netbox 0755 netbox"
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "netbox";
        containerIP = "192.168.7.111";
        containerPort = 8001;

        imports = [ ../users/services/netbox.nix ];
        bindMounts = {
          "/var/lib/netbox/" = { hostPath = "${DATA_DIR}/netbox"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.NetBox_SecretKey.path}".hostPath = config.age.secrets.NetBox_SecretKey.path;
          "${config.age.secrets.NetBox_KeycloakClientSecret.path}".hostPath = config.age.secrets.NetBox_KeycloakClientSecret.path;
        };

        additionalNginxConfig.locations."/static/".alias = "${DATA_DIR}/netbox/static/";

        cfg.services.netbox = {
          enable = true;
          package = pkgs.netbox_3_6;

          secretKeyFile = config.age.secrets.NetBox_SecretKey.path;

        };
      }
    )
  ];
}
