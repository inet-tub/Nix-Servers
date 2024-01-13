{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Keycloak_DatabasePassword = {
      file = ../../secrets/Keycloak/DatabasePassword.age;
      owner = "keycloak";
    };

    Keycloak_SSLCert = {
      file = ../../secrets/Keycloak/SSLCert.age;
      owner = "nginx";
    };

    Keycloak_SSLKey = {
      file = ../../secrets/Keycloak/SSLKey.age;
      owner = "nginx";
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
      file = ../../secrets/HedgeDoc.age;
      owner = "hedgedoc";
    };

    NetBox_SecretKey = {
      file = ../../secrets/NetBox/SecretKey.age;
      owner = "netbox";
    };

    NetBox_KeycloakClientSecret =  {
      file = ../../secrets/NetBox/KeycloakClientSecret.age;
      owner = "netbox";
    };

    WikiJs_SSHKey = {
      file = ../../secrets/SSHKeys/Wiki-js.age;
      owner = "wiki-js";
    };

    VaultWarden_EnvironmentFile = {
      file = ../../secrets/VaultWarden.age;
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
  };
}