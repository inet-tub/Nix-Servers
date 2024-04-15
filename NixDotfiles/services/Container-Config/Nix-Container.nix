{
  name, subdomain ? null, containerIP, containerPort, bindMounts,
  imports ? [], postgresqlName ? null, additionalDomains ? [ ], additionalContainerConfig ? {},
  makeNginxConfig ? true, additionalNginxConfig ? {}, additionalNginxLocationConfig ? {}, additionalNginxHostConfig ? {},
  cfg, lib, config, pkgs
}:
let

  utils = import ../../utils.nix { inherit lib; };
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;
  stateVersion = config.system.stateVersion;

  pgImport = if postgresqlName == null then [] else [
    (
      import ./Postgresql.nix {
        inherit pkgs lib;
        name = postgresqlName;
      }
    )
  ];

  nginxImport = if makeNginxConfig == false then [] else [
    (
      import ./Nginx.nix {
        inherit containerIP config additionalDomains lib;
        containerPort = containerPortStr;
        subdomain = if subdomain != null then subdomain else name;
        additionalConfig = additionalNginxConfig;
        additionalLocationConfig = additionalNginxLocationConfig;
        additionalHostConfig = additionalNginxHostConfig;
      }
    )
  ];

in
{
  imports = imports ++ nginxImport;

  containers."${name}" = utils.recursiveMerge [
    additionalContainerConfig
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = config.host.networking.containerHostIP;
      localAddress = containerIP;

      bindMounts = bindMounts // {
        # Make sure uids and gids are the same
        "/var/lib/nixos".hostPath = "/var/lib/nixos";
        "/etc/passwd".hostPath = "/etc/passwd";
        "/etc/group".hostPath = "/etc/group";
      };

      config = { pkgs, config, lib, ... }: utils.recursiveMerge [
        cfg
        {
          system.stateVersion = stateVersion;
          networking.firewall.allowedTCPPorts = [ containerPort ];
          imports = [ ../../users/root.nix ../../system.nix ] ++ imports ++ pgImport;
        }
      ];
    }
  ];
}
