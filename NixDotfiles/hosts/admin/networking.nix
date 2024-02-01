{ pkgs, config, lib, ...}: {
  inetNetworking.domainName = "inet.tu-berlin.de";
  inetNetworking.containerHostIP = "192.168.7.1";

  networking = {
    useDHCP = false;

    nameservers = [ "130.149.220.253" "130.149.152.187" ];
    search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

    defaultGateway = {
      address = "130.149.152.129";
      interface = "eno1";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };

    interfaces.eno1 = {
      ipv4.addresses = [{
        address = "130.149.152.137";
        prefixLength = 25;
      }];

      ipv6.addresses = [{
        address = "2001:638:809:ff20:130:149:152:137";
        prefixLength = 64;
      }];
    };

    interfaces.eno2 = {
      ipv4.addresses = [{
        address = "192.168.201.137";
        prefixLength = 25;
      }];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };

    # For the containers
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
    };

  };
}
