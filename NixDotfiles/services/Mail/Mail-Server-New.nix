{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/MailServer"; in
{

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/mail-data/ 0750 6000 6000"
    "d ${DATA_DIR}/mail-state/ 0750 6000 6000"
    "d ${DATA_DIR}/mail-logs/ 0750 6000 6000"
    "d ${DATA_DIR}/config/ 0750 6000 6000"
  ];

  # TODO: Exporters:
  #  - dovecot
  #  - postfix
  #  - rspamd
  #  - clamav
  #  - mailman

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "mail";
        image = "mailserver/docker-mailserver:latest";
        subdomain = "en-mail";

        datadir = DATA_DIR;
        containerNum = 0;
        containerPort = 11334;

        additionalContainerConfig.ports = [
          "0.0.0.0:25:25"
          "0.0.0.0:465:465"
          "0.0.0.0:587:587"
          "0.0.0.0:993:993"
          "0.0.0.0:4190:4190"
          "0.0.0.0:11334:11334"
        ];


        environment = {
          DMS_VMAIL_UID = "6000";
          DMS_VMAIL_GID = "6000";

          OVERRIDE_HOSTNAME = "mail.${config.host.networking.domainName}";
          LOG_LEVEL = "trace";
          TZ = "Europe/Berlin";
          ONE_DIR = "1";

          SSL_TYPE = "manual";
          SSL_CERT_PATH = "/var/lib/acme/new-mail.inet.tu-berlin.de/fullchain.pem";
          SSL_KEY_PATH = "/var/lib/acme/new-mail.inet.tu-berlin.de/key.pem";

          ENABLE_QUOTAS = "0";
          ENABLE_MANAGESIEVE = "1";

          # Spam protection with Rspamd
          ENABLE_RSPAMD = "1";
          ENABLE_OPENDKIM = "0";
          ENABLE_OPENDMARC = "0";
          ENABLE_POLICYD_SPF = "0";

          # Virus protection
          ENABLE_AMAVIS = "0"; # Amavis is done by the DFN infront of our servers
          ENABLE_CLAMAV = "0";
        };

        environmentFiles = [ config.age.secrets.Mail_Env.path ];

        volumes = [
          "${DATA_DIR}/mail-data:/var/mail"
          "${DATA_DIR}/mail-state:/var/mail-state"
          "${DATA_DIR}/mail-logs:/var/log/mail"
          "${DATA_DIR}/config:/tmp/docker-mailserver"

          # Overrides
          "/etc/postfix/postfix-main.cf:/tmp/docker-mailserver/postfix-main.cf"
          "/etc/dovecot/dovecot.cf:/tmp/docker-mailserver/dovecot.cf"

          # MailMan
          "/data/MailMan/mailman-core/var/data/:/var/lib/mailman"

          # Certificates
          "${config.age.secrets.Mail_Env.path}:${config.age.secrets.Mail_Env.path}"
          "/var/lib/acme/new-mail.inet.tu-berlin.de/:/var/lib/acme/new-mail.inet.tu-berlin.de/:ro"
        ];
      }
    )
  ];

  environment.etc."postfix/postfix-main.cf".text = ''
    message_size_limit = 26214400000
    mailbox_size_limit = 26214400000

    # MailMan Config
    recipient_delimiter = +
    unknown_local_recipient_reject_code = 550
    owner_request_special = no

    transport_maps = regexp:/var/lib/mailman/postfix_lmtp
    local_recipient_maps = regexp:/var/lib/mailman/postfix_lmtp
    relay_domains = regexp:/var/lib/mailman/postfix_domains

    mynetworks = 10.88.0.0/16
  '';

  environment.etc."dovecot/dovecot.cf".text = ''
    submission_max_mail_size = 262144000
    imap_max_line_length = 67108864
    mail_cache_max_size=200 MB
  '';

}
