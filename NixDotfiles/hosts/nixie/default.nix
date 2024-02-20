{ config, modulesPath, ... }: {
  host = {
    name = "nixie";
    id = "abcd1234";
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
        22 80 443 35621 35623      # Default
        25 465 587 993 4190  # Mail
      ];
    };
  };

  keycloak-setup.realm = "INET";

  monitoredServices = {
    nginx.enable = true;
    nginxlog.enable = true;
    smartctl.enable = true;
    zfs.enable = true;
  };

  # Currently there is no better place to put it as nixie handles inet.tu-berlin.de
  services.nginx.virtualHosts."${config.host.networking.domainName}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.${config.host.networking.domainName}" ];

    globalRedirect = "tu.berlin/eninet";
  };

  services.nginx.virtualHosts."asktheadmins.${config.host.networking.domainName}" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "admin-ticket.${config.host.networking.domainName}";
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./secrets.nix
  ] ++ map (it: ../../services/${it}) [
    # Import services
    "Nginx.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "OnlyOffice.nix"
    "Wiki-js.nix"

    "PasswordManagers/VaultWarden.nix"

    "Mail/MailServer.nix"
    "Mail/MailMan.nix"
    "Mail/WebMail.nix"
  ];
}
