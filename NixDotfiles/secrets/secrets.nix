let
  nixie = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxZbM9HnzXSvxhCqZcnbITckbjqZJGP/BYshk7HA2EEBHJPoDuFjNgICL9iWigB7aUdbZAjOLYQjCYYtpIZsGd/Ul1LZohGBWL3zvQxeB8mOk0Y+47R7RYKieULiCLRmwJMxqmFtYGBWfqo7k/KCVZPVuFAArZk13R9beHRn6dicI8GtHubX2qGQdayUApFHz7l5ZAEWaj31Z0hquRKBzccRzAXTy1P3jthyAum86PgipA+xGxtxjXhleGChBzArUbWEOljzIsbVVpv3wS9Qqr5hJHZrMVWTXAcI8am6k2Abjxcz+vBBFjRV8Gf6zp+2zHH12C5XqqPkh+KYKaRpX6GAsLDgh/xiLfYabm09PiF72HHi1K7IUW+B0dveU/q56gYMdwZgyHCzIUxB7T/LKMHWFPQsO7erUaDT6TUQuyBiKDuCHpWej21rwAPu0iAUGy3sERNT2sOzInGX9VLL61rEW7s1aiiKBKj6821Wr2RjLI7+rUm2nc4e8LIA2reLk=";
  enbackup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdlEoAplZ90VCBYcuYbIEIOoQNO1OKko1mXRfda8uv2 root@enbackup";

  en-observertory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXmHskBbNV4L84enFVlj/x6cmH4jvae2Y+jLexF5RMB root@monitoring";
  authentication = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqrwJxF7Pql+p1XQqH8m9TaSThg35xu5f1R3T7UB0/L root@authentication";

  allSystems = [ nixie enbackup ];
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

  "NetBox/SecretKey.age".publicKeys = [ nixie ];
  "NetBox/KeycloakClientSecret.age".publicKeys = [ nixie ];
  "NetBox.age".publicKeys = [ nixie ];

  "SSHKeys/Wiki-js.age".publicKeys = [ nixie ];

  "Borg/nixie.age".publicKeys = [ enbackup ];
  "Headscale.age".publicKeys = [ enbackup ];
  "BackupPC.age".publicKeys = [ enbackup ];

  "Monitoring/Prometheus/en-observertory-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Nginx/en-observertory-htpasswd.age".publicKeys = [ en-observertory ];

  "Monitoring/Prometheus/authentication-pw.age".publicKeys = [ en-observertory authentication ];
  "Monitoring/Nginx/authentication-htpasswd.age".publicKeys = [ en-observertory authentication ];

  "Monitoring/Grafana/admin-pw.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/secret-key.age".publicKeys = [ en-observertory ];
  "Monitoring/Grafana/mail-pw.age".publicKeys = [ en-observertory ];
}
