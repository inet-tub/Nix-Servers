{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Keycloak_DatabasePassword = {
      file = ../../secrets/Keycloak/DatabasePassword.age;
      owner = "keycloak";
    };

    Keycloak_AdminPassword = {
      file = ../../secrets/Keycloak/AdminPassword.age;
      owner = "keycloak";
    };

    Nextcloud_AdminPassword = {
      file = ../../secrets/Nextcloud/AdminPassword.age;
      owner = "nextcloud";
    };

    Nexcloud_KeycloakClientSecret = {
      file = ../../secrets/Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
    };

    HedgeDoc_EnvironmentFile = {
      file = ../../secrets/HedgeDoc/EnvironmentFile.age;
      owner = "hedgedoc";
    };

    WikiJs_SSHKey = {
      file = ../../secrets/SSHKeys/Wiki-js/key.age;
      owner = "wiki-js";
    };

    VaultWarden_EnvironmentFile = {
      file = ../../secrets/VaultWarden/EnvironmentFile.age;
      owner = "vaultwarden";
    };

    MailMan_EnvironmentFile = {
      file = ../../secrets/Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    MailMan_DatabasePassword = {
      file = ../../secrets/Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    Mail_EnvironmentFile = {
      file = ../../secrets/Mail/EnvironmentFile.age;
      owner = "root";
      group = "root";
    };

    Mail_SSLCerts = {
      file = ../../secrets/Mail/ssl_certs.age;
      owner = "root";
      group = "root";
    };
  };
}