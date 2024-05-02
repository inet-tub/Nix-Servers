{ pkgs, config, lib, ... }:
let
  DATA_DIR = "/data/OpenLDAP";
  LDAP_HOST = "test-ldap.${config.host.networking.domainName}";
in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 openldap openldap"
    "d ${DATA_DIR}/openldap 0750 openldap openldap"
  ];

  systemd.services."container@ldap" = {
    wants = [ "acme-${LDAP_HOST}.service" ];
    after = [ "acme-${LDAP_HOST}.service" ];
  };

  security.acme.certs."${LDAP_HOST}" = {
    group = "openldap";
    postRun = "systemctl reload-or-restart container@ldap";
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "ldap";
        subdomain = "test-ldap";
        containerIP = "192.168.7.113";
        containerPort = 636;

        imports = [ ../../users/services/Authentication/openldap.nix ];
        bindMounts = {
          "/var/lib/openldap/" = { hostPath = "${DATA_DIR}/openldap"; isReadOnly = false; };
          "/var/lib/acme/${LDAP_HOST}" = { hostPath = "/var/lib/acme/${LDAP_HOST}"; };
          "${config.age.secrets.OpenLDAP_rootpw.path}".hostPath = config.age.secrets.OpenLDAP_rootpw.path;
        };

        cfg = {
          services.openldap = {
            # This configrution is greatly ispried by https://github.com/Mic92/dotfiles/blob/main/nixos/modules/openldap/default.nix
            enable = true;
            urlList = [ "ldaps:///" ];

            settings = {

              attrs = {
                olcTLSCACertificateFile = "/var/lib/acme/${LDAP_HOST}/full.pem";
                olcTLSCertificateFile = "/var/lib/acme/${LDAP_HOST}/cert.pem";
                olcTLSCertificateKeyFile = "/var/lib/acme/${LDAP_HOST}/key.pem";
                olcTLSCipherSuite = "HIGH:MEDIUM:!kRSA:!kDHE";
                olcTLSCRLCheck = "none";
                olcTLSVerifyClient = "demand";
                olcTLSProtocolMin = "3.3";
              };

              children = {
                "cn=schema".includes = [
                  "${pkgs.openldap}/etc/schema/core.ldif"
                  "${pkgs.openldap}/etc/schema/cosine.ldif"
                  "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
                ];

                "olcDatabase={1}mdb".attrs = {
                  objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

                  olcDatabase = "{1}mdb";
                  olcDbDirectory = "/var/lib/openldap/data";

                  olcSuffix = "dc=authentication,dc=inet,dc=tu-berlin,dc=de";
                  olcRootDN = "cn=admin,dc=authentication,dc=inet,dc=tu-berlin,dc=de";
                  olcRootPW.path = config.age.secrets.OpenLDAP_rootpw.path;

                  olcAccess = [
                    ''{0}to attrs=userPassword
                           by self write  by anonymous auth
                           by * none''

                    ''{1}to *
                          by * read''
                  ];

                };

              };

            };
          };
        };
      }
    )
  ];
}

