{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Prometheus_en-observertory-pw = {
      file = ../../secrets/Monitoring/Prometheus/en-observertory-pw.age;
      mode = "440";
      owner = "prometheus";
      group = "prometheus";
    };

    Prometheus_authentication-pw = {
      file = ../../secrets/Monitoring/Prometheus/authentication-pw.age;
      owner = "prometheus";
    };

    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/en-observertory-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Grafana_admin-pw = {
      file = ../../secrets/Monitoring/Grafana/admin-pw.age;
      owner = "grafana";
      group = "grafana";
    };

    Grafana_secret-key = {
      file = ../../secrets/Monitoring/Grafana/secret-key.age;
      owner = "grafana";
      group = "grafana";
    };

    Grafana_mail-pw = {
      file = ../../secrets/Monitoring/Grafana/mail-pw.age;
      owner = "grafana";
      group = "grafana";
    };
  };
}