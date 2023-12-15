{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.vaultwarden.members = [ "vaultwarden" ];

  users.users = {
    vaultwarden = {
      isSystemUser = true;
      uid = 5040;
      group = "vaultwarden";
    };
  };
}
