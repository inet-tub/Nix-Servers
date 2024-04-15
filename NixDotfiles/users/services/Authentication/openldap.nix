{ ... }: {
  users.groups.openldap.members = [ "openldap" "nginx" ];

  users.users = {
    openldap = {
      isSystemUser = true;
      uid = 5013;
      group = "openldap";
    };
  };
}
