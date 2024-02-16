{ config, lib, pkgs, ... }:
let
  # Copied from https://github.com/NixOS/nixpkgs/issues/277101#issuecomment-1939187076
  cfg = config.services.urbackup-client;
  settingsFormat = pkgs.formats.keyValue { };

  inherit (lib) types mkOption mkDefault mkDoc mdDoc mkIf mkEnableOption;
in
{
  options.services.urbackup-client = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Enable the UrBackup client daemon.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = mdDoc ''
        User account under which the UrBackup client runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "root";
      description = mdDoc ''
        Group under which the UrBackup client runs.
      '';
    };

    otherSettings = mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Configuration for the UrBackup client. See https://github.com/uroni/urbackup_backend/blob/2.5.x/defaults_client
      '';
    };
  };

  config = {
    users.users = mkIf (cfg.user == "urbackup-client") {
      urbackup-client = {
        group = cfg.group;
        description = "UrBackup client daemon user";
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "urbackup-client") {
      urbackup-client = { };
    };

    # See https://github.com/uroni/urbackup_backend/blob/2.5.x/defaults_client
    services.urbackup-client.otherSettings = {
      # Defaults for urbackup_client initscript

      #logfile name
      LOGFILE = mkDefault "/var/log/urbackup/urbackupclient.log";

      #Either debug,warn,info or error
      LOGLEVEL = mkDefault "debug";

      #Max size of the log file before rotation
      #Disable if you are using logrotate for
      #more advanced configurations (e.g. with compression)
      LOG_ROTATE_FILESIZE = mkDefault 20971520;

      #Max number of log files during rotation
      LOG_ROTATE_NUM = mkDefault 10;

      #Tmp file directory
      DAEMON_TMPDIR = mkDefault "/tmp";

      # Valid settings:
      #
      # "client-confirms": If you have the GUI component the currently active user
      #                    will need to confirm restores from the web interface.
      #                    If you have no GUI component this will cause restores
      #                    from the server web interface to not work
      # "server-confirms": The server will ask the user starting the restore on
      #                    the web interface for confirmation
      # "disabled":        Restores via web interface are disabled.
      #                    Restores via urbackupclientctl still work
      #
      RESTORE = mkDefault "disabled";

      #If true client will not bind to any external network ports (either true or false)
      INTERNET_ONLY = mkDefault false;
    };

    systemd.services.urbackup-client = mkIf cfg.enable {
      description = "UrBackup Client backend";
      after = [ "syslog.target" "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.urbackup-client
        config.boot.zfs.package
      ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.urbackup-client}/bin/urbackupclientbackend --config ${settingsFormat.generate "urbackupclient" cfg.otherSettings} --no-consoletime --loglevel debug";
        StateDirectory = "urbackup urbackup/data";
        WorkingDirectory = "/data/UrBackup/urbackup"; # Overridden by a hardcoded path in the binary
        LogsDirectory = "urbackup";
        AmbientCapabilities = "CAP_SETUID CAP_SYS_NICE";
      };
    };
  };
}