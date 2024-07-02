{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/nixie-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Restic_pw = {
      file = ../../secrets/Backup/Restic/nixie-pw.age;
      owner = "root";
      group = "root";
    };

    Restic_env = {
      file = ../../secrets/Backup/Restic/nixie-env.age;
      owner = "root";
      group = "root";
    };

    Keycloak_Database-Password = {
      file = ../../secrets/Keycloak/Database-Password.age;
      owner = "keycloak";
    };
    Keycloak_SSL-Cert = {
      file = ../../secrets/Keycloak/SSL-Cert.age;
      owner = "nginx";
    };
    Keycloak_SSL-Key = {
      file = ../../secrets/Keycloak/SSL-Key.age;
      owner = "nginx";
    };

    Nextcloud_Admin-Password = {
      file = ../../secrets/Nextcloud/Admin-Password.age;
      owner = "nextcloud";
    };
    Nexcloud_Keycloak-Client-Secret = {
      file = ../../secrets/Nextcloud/Keycloak-Client-Secret.age;
      owner = "nextcloud";
    };
    OnlyOffice-Documentserver = {
      file = ../../secrets/OnlyOffice/Documentserver.age;
      owner = "109";
    };
    OnlyOffice-Communityserver = {
      file = ../../secrets/OnlyOffice/Communityserver.age;
      owner = "109";
    };
    OnlyOffice-Communityserver-Mysql = {
      file = ../../secrets/OnlyOffice/Communityserver-Mysql.age;
      owner = "109";
    };

    HedgeDoc = {
      file = ../../secrets/HedgeDoc.age;
      owner = "hedgedoc";
    };
    WikiJs_SSHKey = {
      file = ../../secrets/SSHKeys/Wiki-js.age;
      owner = "wiki-js";
    };
    VaultWarden = {
      file = ../../secrets/VaultWarden.age;
      owner = "vaultwarden";
    };

    Mail_Env = {
      file = ../../secrets/Mail/MailServer.age;
      owner = "5000";
      group = "5000";
    };
    MailMan_Env = {
      file = ../../secrets/Mail/MailMan.age;
      owner = "100";
      group = "100";
    };

    Wireguard = {
      file = ../../secrets/Office-Gate/Wireguard.age;
      owner = "root";
      group = "root";
    };
  };
}
