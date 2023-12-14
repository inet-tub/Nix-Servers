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
    usePredictableInterfaceNames = false;

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
#      address = "130.149.152.129";
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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpNKIvAaXYU31EBwwbrLuTa4ljiY26F4XboYoOjibVuzIjRZFikcGpLTJr0w7FfsFMkoCHmciPkb6XXZMgDj0LL+mFhVSgg4RW3MmSl5Pqz10qht5gz55gpHh+u/p7wFSi63xKwqmIZ/hEdyBq/c8CS5lsQMWGnPigf7vy/kdBny/La0LEy7bIWouuhGFQtqnYJna2NWQqWyii1LgLWjgwsq/fvWbOxAAcN8iTIX3Q8LXDONPxYGvTbV40R6KhA26m0ZHkMH06cqMUZ4ACfOizz8mf+g+Fuauvj9BZx3No3fKDDOsErZfdqK1Tx93xnO9qrIIDk1cXALKCGMddsgDh0bHzBS82WsqTvQordjkLrXDsXDIz4MRT0DwIUOqFqX29w+yT24ravhGPeOIYSo71y7oMkzGrsHTCM278dRpq6vKUTU8Ct/JRRRvTN5bZLKCI++DllfDCcI24FF1IP8tg/BXto7j1JZBVV4FtlyQBl1QOmXQsxe7HEYUfSifnTkEYCZdrHUwwBEMvUEnYAN3GPt9wbMB2PtOPs4EWbBw6dwkK+WJjMMuNjOzRk3zqKHd7eIlSfZ1CqiraVaSYMa4LRlcbBgZDj9VoYgzl/1Xw2T0YizutHCsqLZVvb1jBtiK9sX7KHh9u9MvpR7H1WOTd4y9MJxcERpwxEo/5m4Zrdw== emily@NYAA"
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
