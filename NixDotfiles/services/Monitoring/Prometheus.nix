{ pkgs, config, lib, ... }:
let

  inherit (lib) foldl';
  DATA_DIR = "/data/Prometheus";
  mkBasicAuth = secretName: { username = "admin"; password_file = config.age.secrets.${secretName}.path; };

  mkScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      basic_auth = mkBasicAuth "Prometheus_${hostname}-pw";
      static_configs = [{ targets = [ "${hostname}.observer.inet.tu-berlin.de" ]; }];
    }] ++ acc)) [ ]
      metrics;

in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 prometheus prometheus"
    "d ${DATA_DIR}/prometheus2 0750 prometheus prometheus"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "prometheus";
        containerIP = "192.168.7.112";
        containerPort = 9090;
        subdomain = "en-observertory";

        imports = [ ../../users/services/Monitoring/prometheus.nix ];
        bindMounts = {
          "/var/lib/prometheus2/" = { hostPath = "${DATA_DIR}/prometheus2"; isReadOnly = false; };
          "${config.age.secrets.Prometheus_nixie-pw.path}".hostPath = config.age.secrets.Prometheus_nixie-pw.path;
          "${config.age.secrets.Prometheus_en-backup-pw.path}".hostPath = config.age.secrets.Prometheus_en-backup-pw.path;
          "${config.age.secrets.Prometheus_en-observertory-pw.path}".hostPath = config.age.secrets.Prometheus_en-observertory-pw.path;
          "${config.age.secrets.Prometheus_authentication-pw.path}".hostPath = config.age.secrets.Prometheus_authentication-pw.path;
          "${config.age.secrets.Prometheus_admin-pw.path}".hostPath = config.age.secrets.Prometheus_admin-pw.path;
        };

        cfg = {
          services.prometheus = {
            enable = true;
            webExternalUrl = "https://en-observertory.${config.host.networking.domainName}";
            webConfigFile = "/var/lib/prometheus2/config/web-config.yaml";

            scrapeConfigs =
              let
                def = [ "zfs" "nginx" ];
              in
              (mkScrapers "nixie" ([ "restic" ] ++ def)) ++
              (mkScrapers "en-backup" ([ ] ++ def)) ++
              (mkScrapers "en-observertory" ([ "prometheus" "restic" ] ++ def)) ++
              (mkScrapers "authentication" ([ "restic" ] ++ def)) ++
              (mkScrapers "admin" ([ "restic" ] ++ def)) ++
              (mkScrapers "en-mail" ([ "restic" ] ++ def))
            ;

          };
        };
      }
    )
  ];
}
