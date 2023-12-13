{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Backup/Duplicati.nix"
    "Backup/UrBackup.nix"
    "Backup/Borg.nix"
    "Backup/Restic.nix"
    "Backup/Rsnapshot.nix"

    "Nginx.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "PasswordManagers/VaultWarden.nix"
    "Wiki-js.nix"
  ];

  keycloak-setup.realm = "INET";
  keycloak-setup.subdomain = "keycloak";
}
