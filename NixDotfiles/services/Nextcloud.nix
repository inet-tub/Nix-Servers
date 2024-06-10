{ pkgs, config, options, lib, ... }:
let
  DATA_DIR = "/data/Nextcloud";
  SUBDOMAIN = "nextcloud";
  nginxConfig = ''
    client_body_buffer_size 400M;
    fastcgi_read_timeout 300s;
    fastcgi_send_timeout 300s;
    fastcgi_connect_timeout 300s;
    proxy_read_timeout 300s;
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 nextcloud"
    "d ${DATA_DIR}/nextcloud 0750 nextcloud"
    "d ${DATA_DIR}/postgresql 0750 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = SUBDOMAIN;
        containerIP = "192.168.7.103";
        containerPort = 80;
        additionalNginxConfig.extraConfig = "client_max_body_size 20G;" + nginxConfig;

        postgresqlName = "nextcloud";
        imports = [ ../users/services/nextcloud.nix ];
        bindMounts = {
          "/var/lib/nextcloud" = { hostPath = "${DATA_DIR}/nextcloud"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Nextcloud_Admin-Password.path}".hostPath = config.age.secrets.Nextcloud_Admin-Password.path;
          "${config.age.secrets.Nexcloud_Keycloak-Client-Secret.path}".hostPath = config.age.secrets.Nexcloud_Keycloak-Client-Secret.path;
        };

        cfg = {
          services.nginx.virtualHosts."cloud.${config.host.networking.domainName}".extraConfig = nginxConfig;

          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud29;
            datadir = "/var/lib/nextcloud";
            hostName = "${SUBDOMAIN}.${config.host.networking.domainName}";
            secretFile = config.age.secrets.Nexcloud_Keycloak-Client-Secret.path;
            https = true;
            maxUploadSize = "20G";

            config = {
              adminuser = "admin";
              adminpassFile = config.age.secrets.Nextcloud_Admin-Password.path;

              dbtype = "pgsql";
              dbhost = "/run/postgresql";
              dbuser = "nextcloud";
              dbname = "nextcloud";
            };

            # Configure the opcache module as recommended
            phpOptions = {
              # Tune Nextcloud
              "pm" = "dynamic";
              "pm.max_children" = "200";
              "pm.start_servers" = "32";
              "pm.min_spare_servers" = "6";
              "pm.max_spare_servers" = "24";

              # Tune OPCache
              "opcache.jit" = "tracing";
              "opcache.jit_buffer_size" = "100M";
              "opcache.interned_strings_buffer" = "16";
              "opcache.max_accelerated_files" = "10000";
              "opcache.memory_consumption" = "1280";
            };

            caching.redis = true;
            configureRedis = true;

            # App config
            appstoreEnable = true;
            extraAppsEnable = true;

            autoUpdateApps.enable = true;
            autoUpdateApps.startAt = "05:00:00";

            extraApps = {
              inherit (pkgs.nextcloud29Packages.apps)
                calendar
                contacts
                deck
#                files_markdown  # Not supported: https://github.com/icewind1991/files_markdown/issues/218
                groupfolders
                notes
                onlyoffice
                ;

              oidc = pkgs.fetchNextcloudApp rec {
                url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.1.1/oidc_login.tar.gz";
                sha256 = "sha256-EVHDDFtz92lZviuTqr+St7agfBWok83HpfuL6DFCoTE=";
                license = "agpl3Only";
              };
            };

            settings = {
              log_type = "file";
              loglevel = 1;
              overwriteprotocol = "https";
              default_phone_region = "DE";
              trusted_proxies = [ config.host.networking.containerHostIP ];

              # Behaviour of OpenID Connect with Keycloak
              oidc_login_provider_url = "https://${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}/realms/${config.keycloak-setup.realm}";
              oidc_login_logout_url = "https://${SUBDOMAIN}.${config.host.networking.domainName}/apps/oidc_login/oidc";
              oidc_login_client_id = "Nextcloud";

              oidc_login_auto_redirect = true;
              oidc_login_end_session_redirect = true;
              oidc_login_use_id_token = false;
              oidc_login_tls_verify = true;
              oidc_login_scope = "openid profile";

              oidc_login_attributes = {
                id = "preferred_username";
                name = "name";
                mail = "email";
                ldap_uid = "uid";
                groups = "groups";
                login_filter = "realm_access_roles";
                photoURL = "picture";
              };

              # Keycloak time settings
              oidc_login_public_key_caching_time = 86400;
              oidc_login_min_time_between_jwks_requests = 10;
              oidc_login_well_known_caching_time = 86400;

              # Appearence of OpenID Connect
              oidc_login_button_text = "Log in with Keycloak";
              oidc_login_hide_password_form = false;

              # Nextcloud config
              allow_user_to_change_display_name = true;
              lost_password_link = "disabled";
              default_locale = "en_IE";
              upgrade.disable-web = false;

              oidc_login_default_group = "Authenticated";
              oidc_login_disable_registration = false;
              oidc_create_groups = true;
              oidc_login_webdav_enabled = true;
              oidc_login_password_authentication = false;

              # File Size limits
              oidc_login_default_quota = "268435456000";
              chunk_size = "512MB";
              max_input_time = "300";
              max_execution_time = "300";
              output_buffering = "0";
              bulkupload.enabled = "false";

              # Calendar
              calendarSubscriptionRefreshRate = "PT1H";
              maintenance_window_start = "1";
            };
          };

          systemd.services."nextcloud-setup" = {
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
          };
        };
      }
    )
  ];
}
