let
  LETSENCRYPT_EMAIL = "root@inet.tu-berlin.de";
in

{ pkgs, config, lib, ... }: {
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    commonHttpConfig = ''
      log_format main
        '$remote_addr - $remote_user [$time_local] '
        '"$request" $status $body_bytes_sent '
        '"$http_referer" "$http_user_agent" '
        'rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"';

    access_log /var/log/nginx/access.log main;
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = LETSENCRYPT_EMAIL;
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx.virtualHosts."_" = {
    default = true;
    locations."/".return = "500";
  };
}
