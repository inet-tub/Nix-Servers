{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/en-backup-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Borg_Encrytpion_Nixie = {
      file = ../../secrets/Borg/nixie.age;
      owner = "borg";
    };

    BackupPC = {
      file = ../../secrets/BackupPC.age;
      owner = "6003";
      group = "6003";
    };

    UrBackup_exporter = {
      file = ../../secrets/UrBackup-exporter.age;
      owner = "6004";
      group = "6004";
    };

  };
}