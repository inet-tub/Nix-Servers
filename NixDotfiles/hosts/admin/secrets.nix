{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/admin-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Restic_pw = {
      file = ../../secrets/Backup/Restic/admin-pw.age;
      owner = "root";
      group = "root";
    };

    Restic_env = {
      file = ../../secrets/Backup/Restic/admin-env.age;
      owner = "root";
      group = "root";
    };

    NetBox_Env = {
      file = ../../secrets/NetBox/Env.age;
      owner = "6050";
      group = "6050";
    };

    NetBox_Postgres = {
      file = ../../secrets/NetBox/PostgresEnv.age;
      owner = "6050";
      group = "6050";
    };

    NetBox_Redis = {
      file = ../../secrets/NetBox/RedisEnv.age;
      owner = "6050";
      group = "6050";
    };
  };
}
