{ pkgs, config, lib, ...}: {
  domainName = "inet.tu-berlin.de";

  networking = {
    useDHCP = false;

    nameservers = [ "130.149.220.253" "130.149.152.187" ];
    search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

    defaultGateway = {
      address = "130.149.152.129";
      interface = "enp2s0f0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp2s0f0";
    };

    interfaces.enp2s0f0 = {
      ipv4.addresses = [{
        address = "130.149.152.130";
        prefixLength = 25;
      }];

      ipv6.addresses = [{
        address = "2001:638:809:ff20:130:149:152:130";
        prefixLength = 64;
      }];
    };

    interfaces.enp2s0f1 = {
      ipv4.addresses = [{
        address = "192.168.201.7";
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
      externalInterface = "enp2s0f0";
    };

  };
}