{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Grafana"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 grafana"
    "d ${DATA_DIR}/grafana 0750 grafana"
    "d ${DATA_DIR}/postgresql 0750 postgres"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "grafana";
        subdomain = "en-monitoring";
        containerIP = "192.168.7.114";
        containerPort = 3000;
        postgresqlName = "grafana";

        imports = [ ../../users/services/Monitoring/grafana.nix ];
        bindMounts = {
          "/var/lib/grafana/" = { hostPath = "${DATA_DIR}/grafana"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Grafana_admin-pw.path}".hostPath = config.age.secrets.Grafana_admin-pw.path;
          "${config.age.secrets.Grafana_secret-key.path}".hostPath = config.age.secrets.Grafana_secret-key.path;
          "${config.age.secrets.Grafana_mail-pw.path}".hostPath = config.age.secrets.Grafana_mail-pw.path;
          "${config.age.secrets.Prometheus_en-observertory-pw.path}".hostPath = config.age.secrets.Prometheus_en-observertory-pw.path;
        };

        cfg = {
          services.grafana = {
            enable = true;
            declarativePlugins = null; # TODO


            settings = {
              server = {
                root_url = "https://en-monitoring.${config.host.networking.domainName}";
                domain = "en-monitoring.${config.host.networking.domainName}";
                enforce_domain = true;
                enable_gzip = true;
                http_addr = "0.0.0.0";
              };

              database = {
                type = "postgres";
                host = "/run/postgresql";
                name = "grafana";
                user = "grafana";
              };

              security = {
                admin_user = "admin";
                admin_password = "$__file{${config.age.secrets.Grafana_admin-pw.path}}";
                admin_email = "admins@inet.tu-berlin.de";

                secret_key = "$__file{${config.age.secrets.Grafana_secret-key.path}}";
                cookie_secure = true;
                cookie_samesite = "lax"; # TODO: "strict"?
                strict_transport_security = false; # TODO
              };

              smtp = {
                enabled = true;
                host = "mail.inet.tu-berlin.de:587";
                user = "grafana@inet.tu-berlin.de";
                password = "$__file{${config.age.secrets.Grafana_mail-pw.path}}";
                from_address = "grafana@inet.tu-berlin.de";
                startTLS_policy = "MandatoryStartTLS";
              };

              users = {
                allow_sign_up = false;
                default_theme = "dark";
              };

              analytics = {
                reporting_enabled = false;
                check_for_updates = true;
                check_for_plugin_updates = true;
              };
            };

            provision = {
              enable = true;

              datasources.settings = {
                apiVersion = 1;
                datasources = [
                  {
                    name = "Prometheus";
                    type = "prometheus";
                    access = "proxy";
                    url = "https://en-observertory.${config.host.networking.domainName}";
                    isDefault = true;
                    jsonData = {
                      basicAuth = true;
                      basicAuthUser = "admin";
                    };
                    secureJsonData = {
                      basicAuthPassword = "$__file{${config.age.secrets.Prometheus_en-observertory-pw.path}}";
                    };
                  }
                ];
              };

              dashboards = {
                settings.providers = [
                  #                  {
                  #                    # TODO
                  #                  }
                ];
              };

              #              alerting = {
              #                rules.settings = {
              #                  apiVersion = 1;
              #
              #                };
              #              };
            };
          };
        };
      }
    )
  ];
}
