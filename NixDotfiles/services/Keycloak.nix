{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Keycloak"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 keycloak"
    "d ${DATA_DIR}/keycloak-data 0755 keycloak"
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "keycloak";
        containerIP = "192.168.7.101";
        containerPort = 80;
        postgresqlName = "keycloak";

        imports = [ ../users/services/keycloak.nix ];
        bindMounts = {
          "/run/keycloak/data" = { hostPath = "${DATA_DIR}/keycloak-data"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Keycloak_DatabasePassword.path}".hostPath = config.age.secrets.Keycloak_DatabasePassword.path;
        };

        additionalNginxConfig.locations."~* ^/(admin|welcome|metrics|health)(/.*)?$".return = "403";
        additionalNginxLocationConfig.extraConfig = ''
          proxy_busy_buffers_size   512k;
          proxy_buffers   4 512k;
          proxy_buffer_size   256k;
        '';

        additionalNginxHostConfig."keycloak-admin.${config.host.networking.domainName}" = {
          forceSSL = true;

          sslCertificate = config.age.secrets.Keycloak_SSLCert.path;
          sslCertificateKey = config.age.secrets.Keycloak_SSLKey.path;

          locations = {
            "/" = {
              proxyPass = "http://192.168.7.101:80";
              extraConfig = ''
                satisfy any;

                allow 192.168.16.0/24;
                allow 192.168.200.0/24;
                allow 192.168.201.0/24;
                allow 192.168.220.0/24;

                deny all;
              '';
            };
          };
        };

        cfg = {
          services.keycloak = {
            enable = true;

            settings = {
              hostname = "keycloak.${config.host.networking.domainName}";
              hostname-admin = "keycloak-admin.${config.host.networking.domainName}";

              hostname-strict-backchannel = true;
              proxy = "edge";
            };

            database = {
              createLocally = false;
              type = "postgresql";
              passwordFile = config.age.secrets.Keycloak_DatabasePassword.path;
            };

            initialAdminPassword = "changeme"; # TODO: Change this

            themes.keywind = pkgs.stdenv.mkDerivation rec {
              name = "keywind";
              src = fetchGit {
                url = "https://github.com/lukin/keywind";
                rev = "6e5ef061bfdaafd7d22a3c812104ffe42aaa55b8";
              };
              installPhase = ''
                mkdir -p $out
                cp -r $src/theme/keywind/* $out/
              '';
            };
          };
        };
      }
    )
  ];
}
