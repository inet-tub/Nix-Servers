{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"

    "Backup/UrBackup.nix"
    "Backup/Borg.nix"
    "Backup/Restic.nix"
    "Backup/Rsnapshot.nix"
  ];
}
