{ pkgs, config, lib, ... }:
{
  networking = {
    firewall.allowedUDPPorts = [ 51820 ];

    nat = {
      enable = true;
      internalInterfaces = [ "wg0" ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "192.168.42.0/25" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.Wireguard.path;

      peers =
        let
          defconfig = {
            endpoint = "${config.host.networking.ip}:51820";
            persistentKeepalive = 30;
          };
        in
        [
          ({
            name = "emily";
            publicKey = "nzezxFukZFM5H7W/1eHGJ75xHb5HBPoOz+rgHvn6Jhc=";
            allowedIPs = [ "192.168.42.1/32" ];
          } // defconfig)

          ({
            name = "darwin";
            publicKey = "sKrxcbDps3d4HGDfcpOaQnYL/yvIb8Tu6JWAliHBjBQ=";
            allowedIPs = [ "192.168.42.2/32" ];
          } // defconfig)
        ];
    };
  };
}
