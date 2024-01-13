{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.netbox.members = [ "netbox" ];

  users.users = {
    netbox = {
      isSystemUser = true;
      uid = 5011;
      group = "netbox";
    };
  };
}
