{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Borg_Encrytpion_Nixie = {
      file = ../../secrets/Borg/nixie.age;
      owner = "borg";
    };

    Headscale_ClientSecret = {
      file = ../../secrets/Headscale.age;
      owner = "headscale";
    };

    BackupPC = {
      file = ../../secrets/BackupPC.age;
      owner = "6003";
      group = "6003";
    };

  };
}