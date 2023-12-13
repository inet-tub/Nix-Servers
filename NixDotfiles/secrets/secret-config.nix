{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Keycloak_DatabasePassword = {
      file = ./Keycloak/DatabasePassword.age;
      owner = "keycloak";
    };

    Keycloak_AdminPassword = {
      file = ./Keycloak/AdminPassword.age;
      owner = "keycloak";
    };

    Nextcloud_AdminPassword = {
      file = ./Nextcloud/AdminPassword.age;
      owner = "nextcloud";
    };

    Nexcloud_KeycloakClientSecret = {
      file = ./Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
    };

    HedgeDoc_EnvironmentFile = {
      file = ./HedgeDoc/EnvironmentFile.age;
      owner = "hedgedoc";
    };

    WikiJs_SSHKey = {
      file = ./SSHKeys/Wiki-js/key.age;
      owner = "wiki-js";
    };

    Duplicati_SSHKey_Nixie = {
      file = ./SSHKeys/Duplicati/nixie.age;
      owner = "1000";
    };

    Borg_Encrytpion_Nixie = {
      file = ./Borg/nixie.age;
      owner = "borg";
    };

    Headscale_ClientSecret = {
      file = ./Headscale/ClientSecret.age;
      owner = "headscale";
    };

    VaultWarden_EnvironmentFile = {
      file = ./VaultWarden/EnvironmentFile.age;
      owner = "vaultwarden";
    };

    MailMan_EnvironmentFile = {
      file = ./Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    MailMan_DatabasePassword = {
      file = ./Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    Mail_EnvironmentFile = {
      file = ./Mail/EnvironmentFile.age;
      owner = "root";
      group = "root";
    };

    Mail_SSLCerts = {
      file = ./Mail/ssl_certs.age;
      owner = "root";
      group = "root";
    };
  };
}