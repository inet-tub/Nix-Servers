{ pkgs, config, lib, ... }: {
  users.users.emily = {
    isNormalUser = true;
    home = "/home/emily";
    description = "Emily Seebeck";

    shell = pkgs.fish;
    createHome = true;
    uid = 1042;
    extraGroups = [ "wheel" ];

    initialHashedPassword = "!";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND9kUmAEwH+qD6T+Gs/G83SA/oyIzpz1Zj4oMAkOvhO emily@work"
    ];

  };
}
