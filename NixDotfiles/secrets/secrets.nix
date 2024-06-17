let
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2ZgWixxR/GhpC/pPqiwuHtKHdMGeg/qAb33MBs6H8T root@nixie";
  en-backup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdlEoAplZ90VCBYcuYbIEIOoQNO1OKko1mXRfda8uv2 root@en-backup";
  en-observertory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXmHskBbNV4L84enFVlj/x6cmH4jvae2Y+jLexF5RMB root@monitoring";
  authentication = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqrwJxF7Pql+p1XQqH8m9TaSThg35xu5f1R3T7UB0/L root@authentication";
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPu5yJRC0EdgEBer1ACyLCLekC6Q6tOH7LdMtGDaZS4O root@admin";
  en-mail = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKLDREmgXHT6s4d+HmFvINkWvc5nMjPOT6FMpX82q8C root@en-mail";
in
{
  # Web stuff
  "Keycloak/Database-Password.age".publicKeys = [ nixie ];
  "Keycloak/SSL-Cert.age".publicKeys = [ nixie ];
  "Keycloak/SSLKey.age".publicKeys = [ nixie ];

  "SSHKeys/Wiki-js.age".publicKeys = [ nixie ];
  "HedgeDoc.age".publicKeys = [ nixie ];
  "VaultWarden.age".publicKeys = [ nixie ];

  "Nextcloud/Admin-Password.age".publicKeys = [ nixie ];
  "Nextcloud/Keycloak-Client-Secret.age".publicKeys = [ nixie ];
  "OnlyOffice/Documentserver.age".publicKeys = [ nixie ];
  "OnlyOffice/Communityserver.age".publicKeys = [ nixie ];
  "OnlyOffice/Communityserver-Mysql.age".publicKeys = [ nixie ];

  "NetBox/PostgresEnv.age".publicKeys = [ admin ];
  "NetBox/RedisEnv.age".publicKeys = [ admin ];
  "NetBox/Env.age".publicKeys = [ admin ];

  # Mail
  "Mail/MailServer.age".publicKeys = [ nixie ];
  "Mail/MailMan.age".publicKeys = [ nixie ];

  # Backup
  "Backup/BackupPC.age".publicKeys = [ en-backup ];
  "Backup/UrBackup-exporter.age".publicKeys = [ en-backup ];

  "Backup/Restic/nixie-htpasswd.age".publicKeys = [ nixie ];
  "Backup/Restic/en-backup-htpasswd.age".publicKeys = [ en-backup ];
  "Backup/Restic/en-observertory-htpasswd.age".publicKeys = [ en-observertory ];
  "Backup/Restic/authentication-htpasswd.age".publicKeys = [ authentication ];
  "Backup/Restic/admin-htpasswd.age".publicKeys = [ admin ];
  "Backup/Restic/en-mail-htpasswd.age".publicKeys = [ en-mail ];

  # Monitoring
  "Monitoring/Grafana/admin-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/secret-key.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/mail-pw.age".publicKeys = [ en-observertory ];

  "Monitoring/Prometheus/en-observertory-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Prometheus/authentication-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Prometheus/en-backup-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Prometheus/admin-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Prometheus/nixie-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Prometheus/en-mail-pw.age".publicKeys = [ en-observertory ];

  "Monitoring/Nginx/en-observertory-htpasswd.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/authentication-htpasswd.age".publicKeys = [ authentication ];
  "Monitoring/Nginx/en-backup-htpasswd.age".publicKeys = [ en-backup ];
  "Monitoring/Nginx/admin-htpasswd.age".publicKeys = [ admin ];
  "Monitoring/Nginx/nixie-htpasswd.age".publicKeys = [ nixie ];
  "Monitoring/Nginx/en-mail-htpasswd.age".publicKeys = [ en-mail ];

  # Authentication
  "Authentication/OpenLDAP-rootpw.age".publicKeys = [ authentication ];
  "Authentication/FreeIPA-rootpw.age".publicKeys = [ authentication ];

  # VPN
  "Wireguard.age".publicKeys = [ authentication ];
  "Headscale.age".publicKeys = [ en-backup ];
}
