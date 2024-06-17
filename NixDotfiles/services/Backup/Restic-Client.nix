{ pkgs, config, lib, ... }: {
  services.restic.backups = {
    en-backup = {
      passwordFile = config.age.secrets.Restic_pw.path;
      environmentFile = config.age.secrets.Restic_env.path;
      repository = "rest:https://restic.${config.host.networking.domainName}/${config.host.name}";

      initialize = true;
      paths = [ "/data" ];

      pruneOpts = [
        "--keep-last 7"
        "--keep-daily 30"
        "--keep-weekly 52"
        "--keep-monthly 120"
        "--keep-yearly 15"
      ];

      timerConfig = {
        # Run every day between 23:00 and 5:00, depending on the random delay
        OnCalendar = "23:00";
        Persistent = true;
        RandomizedDelaySec = "6h";
      };
    };
  };
}
