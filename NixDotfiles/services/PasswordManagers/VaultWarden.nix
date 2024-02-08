{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/VaultWarden"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 vaultwarden"
    "d ${DATA_DIR}/bitwarden_rs 0755 vaultwarden"
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "vaultwarden";
        containerIP = "192.168.7.140";
        containerPort = 8000;
        postgresqlName = "vaultwarden";

        imports = [ ../../users/services/vaultwarden.nix ];
        bindMounts = {
          "/var/lib/bitwarden_rs/" = { hostPath = "${DATA_DIR}/bitwarden_rs"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.VaultWarden_EnvironmentFile.path}".hostPath = config.age.secrets.VaultWarden_EnvironmentFile.path;
        };

        cfg = {
          services.vaultwarden = {
            enable = true;
            environmentFile = config.age.secrets.VaultWarden_EnvironmentFile.path;
            dbBackend = "postgresql";

            config = {
              DATABASE_URL = "postgres://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";
              DOMAIN = "https://vaultwarden.${config.host.networking.domainName}";
              ROCKET_ADDRESS="0.0.0.0";

              SIGNUPS_ALLOWED = false;
              SIGNUPS_VERIFY = true;
              DISABLE_2FA_REMEMBER = true;
              ORG_EVENTS_ENABLED = true;
              EVENTS_DAYS_RETAIN = 30;
              TRASH_AUTO_DELETE_DAYS = 30;

              SMTP_HOST = "smtp.gmail.com";
              SMTP_FROM = "nixie3403@gmail.com";
              SMTP_FROM_NAME = "VaultWarden";
              SMTP_SECURITY = "force_tls";
              SMTP_PORT = "465";
              SMTP_USERNAME = "nixie3403@gmail.com";

            };

          };
        };
      }
    )
  ];
}
