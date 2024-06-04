{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/authentication-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Wireguard = {
      file = ../../secrets/Office-Gate/Wireguard.age;
      owner = "root";
      group = "root";
    };

    OpenLDAP_rootpw = {
      file = ../../secrets/Authentication/OpenLDAP-rootpw.age;
      owner = "openldap";
      group = "openldap";
    };

    FreeIPA_rootpw = {
      file = ../../secrets/Authentication/FreeIPA-rootpw.age;
      owner = "289";
      group = "289";
    };
  };
}
