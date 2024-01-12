{ pkgs, config, lib, ...}:
let
  ENVIRONMENT_CONFIG =  {
    # DB Configuration
    DATABASE_TYPE = "postgres";
    DATABASE_CLASS = "mailman.database.postgresql.PostgreSQLDatabase";

    # Web Configuration
    SERVE_FROM_DOMAIN = "lists.${config.domainName}";
    UWSGI_STATIC_MAP="/static=/opt/mailman-web-data/static";

    # Mail Configuration
    SMTP_HOST = "mail.${config.domainName}";
    MTA = "postfix";
    MAILMAN_ADMIN_USER = "admin";
    MAILMAN_ADMIN_EMAIL = "admins@inet.tu-berlin.de";

    # How containers can reach each other
    POSTORIUS_TEMPLATE_BASE_URL = "http://10.88.2.2:8000";
    HYPERKITTY_URL = "http://10.88.2.2:8000/hyperkitty";
    MAILMAN_REST_URL = "http://10.88.2.1:8001";
    MAILMAN_HOSTNAME = "10.88.2.1";
  };
in
{

  services.nginx.virtualHosts = {
    "lists.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://0.0.0.0:3022/";

      locations."/static/".alias = "/data/MailMan/mailman-web/static/";
      locations."/accounts/signup".return = "403";
    };
  };


  virtualisation.oci-containers.containers.mailman-core = {
    image = "maxking/mailman-core:0.4";

    extraOptions = [ "--ip=10.88.2.1" ];
    ports = [
      "127.0.0.1:8001:8001"
      "127.0.0.1:8024:8024"
    ];

    environment = ENVIRONMENT_CONFIG;
    environmentFiles = [ config.age.secrets.MailMan_EnvironmentFile.path ];

    volumes = [
      "/data/MailMan/mailman-core:/opt/mailman"
    ];

  };

  virtualisation.oci-containers.containers.mailman-web = {
    image = "maxking/mailman-web:0.4";
    extraOptions = [ "--ip=10.88.2.2" ];

    ports = [ "127.0.0.1:3022:8000" ];

    environment = ENVIRONMENT_CONFIG;
    environmentFiles = [ config.age.secrets.MailMan_EnvironmentFile.path ];

    volumes =
    [
      "/data/MailMan/mailman-web:/opt/mailman-web-data"
    ];

  };


  virtualisation.oci-containers.containers.mailman-postgres = {
    image = "postgres:15-alpine";
    extraOptions = [ "--ip=10.88.2.3" ];

    ports = [ "127.0.0.1:5432:5432" ];

    environment = {
      POSTGRES_DB = "mailmandb";
      POSTGRES_USER = "mailman";
    };

    environmentFiles = [ config.age.secrets.MailMan_EnvironmentFile.path ];

    volumes =
    [
      "/data/MailMan/postgresql:/var/lib/postgresql/data"
    ];

  };



  systemd.tmpfiles.rules = [
    "d /data/MailMan/mailman-core 0755 5000 5000"
    "d /data/MailMan/mailman-web 0755 5000 5000"
    "d /data/MailMan/postgresql 0755 5000 5000"
  ];



}