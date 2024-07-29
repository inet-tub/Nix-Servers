{ config, lib, pkgs, ... }:
let
  cfg = config;
  inherit (lib) mkIf types mkOption foldl';

  mkOpt = name: default:
    mkOption {
      description = "Enable ${name} exporter";
      type = types.bool;
      default = default;
    };

in
{

  options.monitoredServices = mkOption {
    description = "Services to monitor";
    default = {};
    type = types.submodule {
      options = {
        # Default options
        hedgedoc = mkOpt "HedgeDoc" cfg.services.hedgedoc.enable;
        nextcloud = mkOpt "Nextcloud" cfg.services.nextcloud.enable;
        nginx = mkOpt "Nginx" cfg.services.nginx.enable;
        nginxlog = mkOpt "Nginxlog" cfg.services.nginx.enable;
        prometheus = mkOpt "Prometheus" cfg.services.prometheus.enable;
        restic = mkOpt "Restic" (cfg.services.restic.backups != {});
        zfs = mkOpt "ZFS" cfg.boot.zfs.enabled;
        netbox = mkOpt "Netbox" false;

        # TODO
#        wireguard = mkOpt "Wireguard";
#        postgres = mkOpt "Postgres";
#        bind = mkOpt "Bind DNS Server";
#        idrac = mkOpt "iDRAC";
#        ipmi = mkOpt "IPMI";
#        smartctl = mkOpt "Smartctl";  # TODO: devices
#        mail = TODO;
#        keycloak = TODO;
#        onlyoffice = TODO;
      };
    };

  };

  # Fake exporters
#  options.services.prometheus.exporters = {
#    smartctl.telemetryPath = mkOption {
#      description = "FAKE OPTION (this does nothing): Path to smartctl metrics";
#      type = types.str;
#      default = "/smartctl-metrics";
#    };
#  };


  config = {

    # Enable all exporters that do not require additional configuration
    services.prometheus.exporters = foldl'
      (acc: it: {
        "${it}" = mkIf cfg.monitoredServices.${it} {
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


      nginxlog = mkIf cfg.monitoredServices.nginxlog {
        enable = true;
        group = "nginx";  # Needed for access to the log file
        metricsEndpoint = "/nginxlog-metrics";

        settings.namespaces = [{
          name = "nginxlog";
          format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" rt=$request_time uct=\"$upstream_connect_time\" uht=\"$upstream_header_time\" urt=\"$upstream_response_time\"";
          source.files = [ "/var/log/nginx/access.log" ];
        }];
      };

#      smartctl = mkIf cfg.monitoredServices.smartctl {
#        enable = true;
#        devices = cfg.monitoredServices.smartctl.devices;
#        extraFlags = [ "--web.telemetry-path=/smartctl-metrics" ];
#      };

    };

    # Enable monitoring options of services
    services.nginx.statusPage = cfg.monitoredServices.nginx;
    systemd.services."prometheus-nginx-exporter" = mkIf cfg.monitoredServices.nginx {
      after = [ "nginx.service" ];
    };

    # Enable Docker monitoring
    virtualisation.oci-containers.containers.restic-exporter = mkIf cfg.monitoredServices.restic {
      image = "ngosang/restic-exporter";
      ports = [ "127.0.0.1::8001" ];
      extraOptions = [ "--ip=10.88.5.2" "--userns=keep-id" ];

      volumes = [
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "${config.age.secrets.Restic_pw.path}:${config.age.secrets.Restic_pw.path}"
        "${config.age.secrets.Restic_env.path}:${config.age.secrets.Restic_env.path}"
      ];

      environment = {
        TZ = "Europe/Berlin";
        RESTIC_REPOSITORY = "rest:https://restic.${config.host.networking.domainName}/${config.host.name}";
        RESTIC_PASSWORD_FILE = config.age.secrets.Restic_pw.path;
        REFRESH_INTERVAL="900";  # 15min
        NO_CHECK="True";
      };
      environmentFiles = [ config.age.secrets.Restic_env.path ];
    };

    # Finally, setup the correct nginx paths
    services.nginx.virtualHosts = mkIf (config.monitoredServices != { }) {
      "${config.host.name}.observer.${config.host.networking.domainName}" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;

        locations = foldl'
          # First the exporters that are simply passed through
          (acc: it: {
            "/${it}-metrics".proxyPass = mkIf cfg.monitoredServices."${it}" "http://127.0.0.1:${toString cfg.services.prometheus.exporters.${it}.port}";
          } // acc)
          { "/".return = "403"; } [ "zfs" "nginx" "nginxlog" ] // {

          # Now the exporters that require additional configuration
          "/prometheus-metrics".proxyPass = mkIf cfg.monitoredServices.prometheus "http://192.168.7.112:9090/metrics";
          "/restic-metrics".proxyPass = mkIf cfg.monitoredServices.restic "http://10.88.5.2:8001/metrics";
          "/hedgedoc-metrics".proxyPass = mkIf cfg.monitoredServices.hedgedoc "http://192.168.7.104:3000/metrics";
          "/nextcloud-metrics".proxyPass = mkIf cfg.monitoredServices.nextcloud "http://192.168.7.103:9205/metrics";
          "/netbox-metrics".proxyPass = mkIf cfg.monitoredServices.netbox "http://10.88.5.1:8000/metrics";
        };
      };
    };
  };

}
