{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/en-mail-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Restic_pw = {
      file = ../../secrets/Backup/Restic/en-mail-pw.age;
      owner = "root";
      group = "root";
    };

    Restic_env = {
      file = ../../secrets/Backup/Restic/en-mail-env.age;
      owner = "root";
      group = "root";
    };
  };
}
