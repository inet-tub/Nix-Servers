{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Restic"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 restic nginx"
    "d ${DATA_DIR}/restic 0750 restic nginx"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "restic";
        subdomain = "restic";
        containerIP = "192.168.7.115";
        containerPort = 8000;

        additionalNginxConfig.basicAuthFile = config.age.secrets.Restic_pw.path;
        additionalNginxLocationConfig.extraConfig = "client_max_body_size 1000M;";

        imports = [ ../../users/services/restic.nix ];
        bindMounts = {
          "/var/lib/restic/" = { hostPath = "${DATA_DIR}/restic"; isReadOnly = false; };
        };

        cfg.services.restic.server = {
          enable = true;
          appendOnly = true;  # Backups should not be deleted
          privateRepos = true;
          prometheus = true;
          extraFlags = [ "--no-auth" "--prometheus-no-auth" ];  # Authentication is handled by nginx
        };
      }
    )
  ];
}
