{ ... }: {
  imports = [ ./postgres.nix ];
  # Nginx servs the static files and thus needs access to nextcloud files
  users.groups.nextcloud.members = [ "nextcloud" "nginx" ];
  users.groups.nextcloud-exporter.members = [ "nextcloud-exporter" ];

  users.users = {
    nextcloud = {
      isSystemUser = true;
      uid = 5002;
      group = "nextcloud";
    };

    nextcloud-exporter = {
      isSystemUser = true;
      uid = 5102;
      group = "nextcloud-exporter";
    };
  };
}
