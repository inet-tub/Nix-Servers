{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/authentication-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Restic_pw = {
      file = ../../secrets/Backup/Restic/authentication-pw.age;
      owner = "root";
      group = "root";
    };

    Restic_env = {
      file = ../../secrets/Backup/Restic/authentication-env.age;
      owner = "root";
      group = "root";
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

    FreeIPA_install-command = {
      file = ../../secrets/Authentication/FreeIPA_install-command.age;
      owner = "289";
      group = "289";
    };
  };
}
