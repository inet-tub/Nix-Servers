{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/authentication-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };
  };
}