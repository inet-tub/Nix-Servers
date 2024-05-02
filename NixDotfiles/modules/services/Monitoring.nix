{ config, lib, pkgs, ... }:
let
  cfg = config;
  inherit (lib) mkIf types mkOption foldl';

in
{

  options.monitoredServices = mkOption {
    description = "Services to monitor";
    type = types.submodule {
      options = {
        bind = mkOption {
          description = "Bind DNS server";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable bind exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        idrac = mkOption {
          description = "iDRAC";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable iDRAC exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        ipmi = mkOption {
          description = "IPMI";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable IPMI exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        nextcloud = mkOption {
          description = "Nextcloud";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable nextcloud exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        openldap = mkOption {
          description = "OpenLDAP";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable openldap exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        nginx = mkOption {
          description = "Nginx";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable nginx exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        nginxlog = mkOption {
          description = "Nginx";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable nginx exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        postgres = mkOption {
          description = "Postgres";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable postgres exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        prometheus = mkOption {
          description = "Prometheus";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable prometheus exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        smartctl = mkOption {
          description = "Smartctl";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable smartctl exporter";
                type = types.bool;
                default = false;
              };

              devices = mkOption {
                description = "Devices to monitor";
                type = types.listOf types.str;
                default = cfg.host.bootDevices;
              };
            };
          });
        };

        zfs = mkOption {
          description = "ZFS";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable zfs exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        urbackup = mkOption {
          description = "UrBackup";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable urbackup exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

      };
    };

  };

  # Fake exporters
  options.services.prometheus.exporters = {
    smartctl.telemetryPath = mkOption {
      description = "FAKE OPTION (this does nothing): Path to smartctl metrics";
      type = types.str;
      default = "/smartctl-metrics";
    };
  };


  config = {

    # Enable all exporters that do not require additional configuration
    services.prometheus.exporters = foldl'
      (acc: it: {
        "${it}" = mkIf cfg.monitoredServices.${it}.enable {
          enable = true;
          telemetryPath = "/${it}-metrics";
        };
      } // acc)
      { } [ "nginx" "zfs" ] // {

      # Now add the exporters that require additional configuration
      # bind = {};
      # openldap = {};
      # idrac = {};
      # impi = {};
      # nextcloud = {};
      # postgres = {};

      nginxlog = mkIf (cfg.monitoredServices.nginxlog != null) {
        enable = true;
        metricsEndpoint = "/nginxlog-metrics";
      };

      smartctl = mkIf (cfg.monitoredServices.smartctl != null) {
        enable = true;
        devices = cfg.monitoredServices.smartctl.devices;
        extraFlags = [ "--web.telemetry-path=/smartctl-metrics" ];
      };

    };

    # Enable monitoring options of services
    services.nginx.statusPage = cfg.monitoredServices.nginx != null;
    systemd.services."prometheus-nginx-exporter" = mkIf (cfg.monitoredServices.nginx != null) {
      after = [ "nginx.service" ];
    };

    # Enable Docker monitoring
    virtualisation.oci-containers.containers.urbackup-exporter = mkIf (cfg.monitoredServices.urbackup != null) {
      image = "ngosang/urbackup-exporter";
      ports = [ "127.0.0.1::9554" ];
      extraOptions = [ "--ip=10.88.4.2" "--userns=keep-id" ];
      volumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ];
      environment = {
        TZ = "Europe/Berlin";
        URBACKUP_SERVER_URL = "http://10.88.4.1:55414/x";
        URBACKUP_SERVER_USERNAME = "admin";
        EXPORT_CLIENT_BACKUP = "true";
      };
      environmentFiles = [ config.age.secrets.UrBackup_exporter.path ];
    };

    services.nginx.virtualHosts = mkIf (config.monitoredServices != [ ]) {
      "${config.host.name}.observer.${config.host.networking.domainName}" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;

        locations = foldl'
          (acc: it: {
            "/${it}-metrics".proxyPass = "http://127.0.0.1:${toString cfg.services.prometheus.exporters.${it}.port}";
          } // acc)
          { "/".return = "403"; } [ "zfs" "smartctl" "nginx" "nginxlog" ] // {
          "/prometheus-metrics".proxyPass = "http://192.168.7.112:9090/metrics";
          "/backuppc-metrics".proxyPass = "http://10.88.3.1:8080/BackupPC_Admin?action=metrics&format=prometheus";
          "/urbackup-metrics".proxyPass = "http://10.88.4.2:9554/metrics";
        };
      };
    };
  };

}
