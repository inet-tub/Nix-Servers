{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/OpenLDAP"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 openldap openldap"
    "d ${DATA_DIR}/openldap 0755 openldap openldap"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "ldap";
        makeNgnixConfig = false;
        containerIP = "192.168.7.113";
        containerPort = 80;

        imports = [ ../users/services/openldap.nix ];
        bindMounts = {
          "/var/lib/openldap/" = { hostPath = "${DATA_DIR}/openldap"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
        };

        cfg.openldap = {
#          enable = true;

        };
      }
    )
  ];
}
