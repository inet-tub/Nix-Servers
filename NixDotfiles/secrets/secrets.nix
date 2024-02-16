let
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2ZgWixxR/GhpC/pPqiwuHtKHdMGeg/qAb33MBs6H8T root@nixie";
  en-backup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdlEoAplZ90VCBYcuYbIEIOoQNO1OKko1mXRfda8uv2 root@en-backup";

  en-observertory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXmHskBbNV4L84enFVlj/x6cmH4jvae2Y+jLexF5RMB root@monitoring";
  authentication = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqrwJxF7Pql+p1XQqH8m9TaSThg35xu5f1R3T7UB0/L root@authentication";
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPu5yJRC0EdgEBer1ACyLCLekC6Q6tOH7LdMtGDaZS4O root@admin";

  allSystems = [ nixie en-backup en-observertory authentication admin ];
in
{
  "Keycloak/DatabasePassword.age".publicKeys = [ nixie ];
  "Keycloak/SSLCert.age".publicKeys = [ nixie ];
  "Keycloak/SSLKey.age".publicKeys = [ nixie ];

  "HedgeDoc.age".publicKeys = [ nixie ];
  "VaultWarden.age".publicKeys = [ nixie ];

  "Nextcloud/AdminPassword.age".publicKeys = [ nixie ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ nixie ];
  "OnlyOffice.age".publicKeys = [ nixie ];

  "Mail/EnvironmentFile.age".publicKeys = [ nixie ];
  "Mail/MailManEnvironmentFile.age".publicKeys = [ nixie ];
  "Mail/MailManDatabasePassword.age".publicKeys = [ nixie ];

  "NetBox.age".publicKeys = [ nixie ];
  "NetBox/PostgresEnv.age".publicKeys = [ admin ];
  "NetBox/RedisEnv.age".publicKeys = [ admin ];
  "NetBox/Env.age".publicKeys = [ admin ];

  "SSHKeys/Wiki-js.age".publicKeys = [ nixie ];

  "Borg/nixie.age".publicKeys = [ en-backup ];
  "Headscale.age".publicKeys = [ en-backup ];
  "BackupPC.age".publicKeys = [ en-backup ];
  "UrBackup-exporter.age".publicKeys = [ en-backup ];

  "Monitoring/Prometheus/en-observertory-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/en-observertory-htpasswd.age".publicKeys = [ en-observertory ];

  "Monitoring/Prometheus/authentication-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/authentication-htpasswd.age".publicKeys = [ authentication ];

  "Monitoring/Prometheus/en-backup-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/en-backup-htpasswd.age".publicKeys = [ en-backup ];

  "Monitoring/Prometheus/admin-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/admin-htpasswd.age".publicKeys = [ admin ];

  "Monitoring/Prometheus/nixie-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/nixie-htpasswd.age".publicKeys = [ nixie ];

  "Monitoring/Grafana/admin-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/secret-key.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/mail-pw.age".publicKeys = [ en-observertory ];

  "Test.age".publicKeys = [ admin ];
}
