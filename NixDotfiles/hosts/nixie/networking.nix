{ pkgs, config, lib, ...}: {
  domainName = "inet.tu-berlin.de";

  networking = {
    useDHCP = false;

    nameservers = [ "130.149.220.253" "130.149.152.187" ];
    search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

    defaultGateway = {
      address = "130.149.220.126";
      interface = "eno1";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };

    interfaces.eno1 = {
      ipv4.addresses = [{
        address = "130.149.220.7";
        prefixLength = 25;
      }];

      ipv6.addresses = [{
        address = "2001:638:809:ff11:130:149:220:7";
        prefixLength = 64;
      }];
    };

    interfaces.eno2 = {
      ipv4.addresses = [{
        address = "192.168.200.8";
        prefixLength = 25;
      }];
    };

    interfaces.eno3 = {
      ipv4.addresses = [{
        address = "130.149.220.241";
        prefixLength = 32;
      }];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 25 80 443 465 587 993 4190 ];
    };

    # For the containers
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
    };

  };
}