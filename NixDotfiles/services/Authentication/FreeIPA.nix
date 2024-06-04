{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/FreeIPA"; in
{

  networking.firewall.allowedTCPPorts = [ 389 636 88 464 ];
  networking.firewall.allowedUDPPorts = [ 88 464 123 ];

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "freeipa";
        image = "freeipa/freeipa-server:almalinux-9";

        dataDir = DATA_DIR;
        containerNum = 7;
        containerPort = 443;
        additionalPorts = [
          # LDAP / LDAPS
          "0.0.0.0:389:389"
          "0.0.0.0:636:636"

          # Kerberos
          "0.0.0.0:88:88"
          "0.0.0.0:88:88/udp"
          "0.0.0.0:464:464"
          "0.0.0.0:464:464/udp"

          # NTP
        ];
        environment = {
          IPA_SERVER_IP = "10.88.7.1";
          IPA_SERVER_HOSTNAME = "freeipa.${config.host.networking.domainName}";
          DEBUG_TRACE = "1";
          DEBUG_NO_EXIT = "1";
        };
        environmentFiles = [ config.age.secrets.FreeIPA_rootpw.path ];

        volumes = [
          "${DATA_DIR}/data:/data"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 289 289"
    "d ${DATA_DIR}/data/ 0750 289 289"
  ];
}
