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

        nginxUseHttps = true;
        additionalNginxConfig = {
          sslCertificate = "/var/lib/acme/freeipa.inet.tu-berlin.de/httpd.crt";
          sslCertificateKey = "/var/lib/acme/freeipa.inet.tu-berlin.de/httpd.key";
          enableACME = lib.mkForce false;
        };
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
          "/var/lib/acme/freeipa.${config.host.networking.domainName}:/var/lib/acme"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 root root"

    # This directory has to be readable by everyone as there are multiple users that depend on it
    "d ${DATA_DIR}/data/ 0755 root root"
  ];
}
