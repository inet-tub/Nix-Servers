{ pkgs, pkgs-unstable, config, lib, ... }: {
  security.ipa = {
    enable = true;

    certificate = pkgs.fetchurl {
      url = "https://freeipa.inet.tu-berlin.de/ipa/config/ca.crt";
      sha256 = "0bqnvsmfv9s512bzjs9cnj6p95pqbvd2wpqp43zriwmflzwgaxxy";
    };

    domain = "inet.tu-berlin.de";
    realm = "INET.TU-BERLIN.DE";
    server = "freeipa.inet.tu-berlin.de";
    basedn = "dc=inet,dc=tu-berlin,dc=de";

    dyndns.enable = false;
    chromiumSupport = false;

  };

  environment.systemPackages = [
    pkgs.freeipa
  ];
}
