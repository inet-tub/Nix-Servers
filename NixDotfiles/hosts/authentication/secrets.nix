{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/authentication-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Wireguard = {
      file = ../../secrets/Wireguard.age;
      owner = "root";
      group = "root";
    };

    OpenLDAP_rootpw = {
      file = ../../secrets/OpenLDAP-rootpw.age;
      owner = "openldap";
      group = "openldap";
    };
  };
}