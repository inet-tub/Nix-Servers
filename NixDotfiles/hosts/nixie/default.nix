{ config, modulesPath, ... }: {
  host = {
    name = "nixie";
    id = "hostid_placeholder";
    bootDevices = [ "bootDevices_placeholder" ];

    zfsAutoSnapshot = {
      enable = true;
      weekly = 7;
      monthly = 48;
    };

    zfsArc = {
      minGB = 24;
      maxGB = 48;
      metaGB = 12;
    };

    networking = {
      ip = "130.149.220.242";
      interface = "eno1";

      adminIp = "192.168.200.7";
      adminInterface = "eno2";

      location = "mar";
      networkRange = "dmz";

      firewallAllowedTCPPorts = [
        # Default
        22
        80
        443
        35621
        35623

        # Mail
        25
        465
        587
        993
        4190
      ];
    };
  };

  keycloak-setup.realm = "INET";

  monitoredServices = {
    # TODO: This is currently needed because deteriming if nextcloud.enable is true is not possible from outside of the container
    hedgedoc = true;
    nextcloud = true;
  };

  # Currently there is no better place to put it as nixie handles inet.tu-berlin.de
  services.nginx.virtualHosts."${config.host.networking.domainName}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.${config.host.networking.domainName}" ];

    globalRedirect = "tu.berlin/eninet";
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    "Nginx.nix"
    "Backup/Restic-Client.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "OnlyOffice.nix"
    "Wiki-js.nix"

    "PasswordManagers/VaultWarden.nix"

    "Wireguard.nix"

    "Mail/MailServer.nix"
    "Mail/MailMan.nix"
    "Mail/WebMail.nix"
  ];
}
