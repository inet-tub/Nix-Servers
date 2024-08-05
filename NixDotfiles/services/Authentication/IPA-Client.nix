{ pkgs, pkgs-unstable, config, lib, ... }: {
  security.ipa = {
    enable = true;

    domain = "inet.tu-berlin.de";
    realm = "INET.TU-BERLIN.DE";
    server = "ipa.inet.tu-berlin.de";
    basedn = "dc=inet,dc=tu-berlin,dc=de";

    cacheCredentials = true;
    offlinePasswords = true;

    certificate = pkgs.fetchurl {
      url = "https://ipa.inet.tu-berlin.de/ipa/config/ca.crt";
      sha256 = "19lr6gdcwjnqa1zdhd3zi11lcw7rljpyalzns39bm40yqr7ssnd4";
    };

    dyndns.enable = false;
    chromiumSupport = false;
  };

  environment.systemPackages = [
    pkgs.freeipa
  ];
}
