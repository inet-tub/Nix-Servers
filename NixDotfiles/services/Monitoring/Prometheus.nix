{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Prometheus"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 prometheus prometheus"
    "d ${DATA_DIR}/prometheus2 0755 prometheus prometheus"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "prometheus";
        containerIP = "192.168.7.112";
        containerPort = 9090;

        imports = [ ../users/services/Monitoring/prometheus.nix ];
        bindMounts = {
          "/var/lib/prometheus2/" = { hostPath = "${DATA_DIR}/prometheus2"; isReadOnly = false; };
          "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
        };

        cfg = {
          prometheus = {
#            enable = true;

          };
        };
      }
    )
  ];
}
