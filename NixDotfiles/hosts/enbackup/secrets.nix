{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Borg_Encrytpion_Nixie = {
      file = ../../secrets/Borg/nixie.age;
      owner = "borg";
    };

    Headscale_ClientSecret = {
      file = ../../secrets/Headscale/ClientSecret.age;
      owner = "headscale";
    };

  };
}