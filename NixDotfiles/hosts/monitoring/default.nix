{ config, modulesPath, ... }: {
  host = {
    name = "monitoring";
    id = "abcd1234";
    bootDevices = [ "bootDevices_placeholder" ];

    zfsAutoSnapshot = {
      weekly = 7;
      monthly = 120;
    };

    zfsArc = {
      minGB = 8;
      maxGB = 48;
      metaGB = 12;
    };

    inetNetworking = {
      ip = "130.149.152.135";
      location = "en";
      networkRange = "ennet";
      interface = "eno1";
    };
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"
  ];
}
