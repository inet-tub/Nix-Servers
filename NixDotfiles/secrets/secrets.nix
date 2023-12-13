let
  nixie = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxZbM9HnzXSvxhCqZcnbITckbjqZJGP/BYshk7HA2EEBHJPoDuFjNgICL9iWigB7aUdbZAjOLYQjCYYtpIZsGd/Ul1LZohGBWL3zvQxeB8mOk0Y+47R7RYKieULiCLRmwJMxqmFtYGBWfqo7k/KCVZPVuFAArZk13R9beHRn6dicI8GtHubX2qGQdayUApFHz7l5ZAEWaj31Z0hquRKBzccRzAXTy1P3jthyAum86PgipA+xGxtxjXhleGChBzArUbWEOljzIsbVVpv3wS9Qqr5hJHZrMVWTXAcI8am6k2Abjxcz+vBBFjRV8Gf6zp+2zHH12C5XqqPkh+KYKaRpX6GAsLDgh/xiLfYabm09PiF72HHi1K7IUW+B0dveU/q56gYMdwZgyHCzIUxB7T/LKMHWFPQsO7erUaDT6TUQuyBiKDuCHpWej21rwAPu0iAUGy3sERNT2sOzInGX9VLL61rEW7s1aiiKBKj6821Wr2RjLI7+rUm2nc4e8LIA2reLk=";

  systems = [ nixie ];
in
{
  "Keycloak/DatabasePassword.age".publicKeys = [ nixie ];
  "Keycloak/AdminPassword.age".publicKeys = [ nixie ];

  "Nextcloud/AdminPassword.age".publicKeys = [ nixie ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ nixie ];

  "HedgeDoc/EnvironmentFile.age".publicKeys = [ nixie ];
  "VaultWarden/EnvironmentFile.age".publicKeys = [ nixie ];

  "Mail/MailManEnvironmentFile.age".publicKeys = [ nixie ];
  "Mail/MailManDatabasePassword.age".publicKeys = [ nixie ];

  "Mail/ssl_certs.age".publicKeys = [ nixie ];
  "Mail/EnvironmentFile.age".publicKeys = [ nixie ];

  "SSHKeys/Wiki-js/key.age".publicKeys = [ nixie ];
  "SSHKeys/Duplicati/nixie.age".publicKeys = [ nixie ];

  "Borg/nixie.age".publicKeys = [ nixie ];
  "Headscale/ClientSecret.age".publicKeys = [ nixie ];
}