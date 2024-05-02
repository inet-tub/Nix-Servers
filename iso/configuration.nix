{ pkgs, inputs, lib, config, ... }:
let

  inherit (inputs) self;
  rootConfig = import ../NixDotfiles/users/root.nix { inherit pkgs inputs lib config; };

in
{
  imports = [
    ../NixDotfiles/system.nix
  ];

  # Set static IP
  networking = {
    useDHCP = false;
#    usePredictableInterfaceNames = false;

    nameservers = [ "130.149.220.253" "130.149.152.187" ];
    search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

    # EN
    defaultGateway = {
      address = "130.149.152.129";
      interface = "eth0";
    };

    interfaces.eth0.ipv4.addresses = [{
      address = "130.149.152.159";  # EN
      prefixLength = 25;
    }];

    # MAR
#    defaultGateway = {
#      address = "130.149.220.TODO";
#      interface = "eth0";
#    };
#
#    interfaces.eth0.ipv4.addresses = [{
#      address = "130.149.220.126";  # MAR
#      prefixLength = 25;
#    }];
  };

  # Copy the existing config
  environment.systemPackages = rootConfig.environment.systemPackages;
  programs = rootConfig.programs;
  services.openssh = rootConfig.services.openssh;

  users.users = {
    root = {
      initialHashedPassword = "";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND9kUmAEwH+qD6T+Gs/G83SA/oyIzpz1Zj4oMAkOvhO emily@work"
      ];

      shell = pkgs.fish;
    };

    nixos.shell = pkgs.fish;
  };

  environment.defaultPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
  ];

  # Override the default configuration
  boot.swraid.enable = lib.mkForce false;
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}
