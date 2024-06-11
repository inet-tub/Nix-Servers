{ pkgs, pkgs-unstable, config, lib, ... }: {
  security.ipa = {
    enable = true;

    certificate = pkgs.fetchurl {
      url = "https://ipa.example.com/ipa/config/ca.crt";
      sha256 = "0jhxzggc2bm55mg2id7pzpfkm2jyj1zyy6jzsn3j37b0hnjp0dch";
    };

    domain = "inet.tu-berlin.de";
    realm = "INET.TU-BERLIN.DE";
    server = "freeipa.inet.tu-berlin.de";
    basedn = "dc=inet,dc=tu-berlin,dc=de";

    dyndns.enable = false;
    chromiumSupport = false;

  };

  environment.systemPackages = [
    pkgs-unstable.freeipa
  ];
}
