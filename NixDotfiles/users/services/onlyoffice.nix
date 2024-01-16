{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.onlyoffice.members = [ "onlyoffice" ];
  users.groups.rabbitmq.members = [ "rabbitmq" ];

  users.users = {
    onlyoffice = {
      isSystemUser = true;
      uid = 5011;
      group = "onlyoffice";
    };

    rabbitmq = {
      isSystemUser = true;
      uid = 85;
      group = "rabbitmq";
    };
  };
}
