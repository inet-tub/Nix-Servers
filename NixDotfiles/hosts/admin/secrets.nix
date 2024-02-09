{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/admin-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };
  };
}