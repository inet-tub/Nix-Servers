{ ... }: {
  users.groups.prometheus.members = [ "prometheus" ];

  users.users = {
    prometheus = {
      isSystemUser = true;
      uid = 5012;
      group = "prometheus";
    };
  };
}
