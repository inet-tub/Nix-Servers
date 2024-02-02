{ ... }: {
  users.groups.openldap.members = [ "openldap" ];

  users.users = {
    openldap = {
      isSystemUser = true;
      uid = 5013;
      group = "openldap";
    };
  };
}
