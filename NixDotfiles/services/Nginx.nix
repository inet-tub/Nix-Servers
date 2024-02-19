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
