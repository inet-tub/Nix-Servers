{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "OnlyOffice.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "NetBox.nix"

    "PasswordManagers/VaultWarden.nix"

    "Mail/MailServer.nix"
    "Mail/MailMan.nix"
    "Mail/WebMail.nix"
  ];

  keycloak-setup.realm = "INET";
}
