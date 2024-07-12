{ pkgs, config, lib, ... }: {
  services.restic.backups = {
    en-backup = {
      passwordFile = config.age.secrets.Restic_pw.path;
      environmentFile = config.age.secrets.Restic_env.path;
      repository = "rest:https://restic.${config.host.networking.domainName}/${config.host.name}";

      initialize = true;
      paths = [ "/data" ];

      timerConfig = {
        # Run every day between 23:00 and 5:00, depending on the random delay
        OnCalendar = "23:00";
        Persistent = true;
        RandomizedDelaySec = "6h";
      };
    };
  };
}
