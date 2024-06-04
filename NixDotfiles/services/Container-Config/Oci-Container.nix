{ name
, image
, dataDir
, subdomain ? null
, containerNum
, containerSubNum ? 1
, containerPort
, volumes
, makeLocaltimeVolume ? true
, imports ? [ ]
, postgresEnvFile ? null
, mysqlEnvFile ? null
, redisEnvFile ? null
, environment ? { }
, environmentFiles ? [ ]
, additionalPorts ? [ ]
, additionalDomains ? [ ]
, additionalContainerConfig ? { }
, makeNginxConfig ? true
, additionalNginxConfig ? { }
, additionalNginxLocationConfig ? { }
, additionalNginxHostConfig ? { }
, config
, lib
, pkgs
}:
let

  inherit (lib) mkIf optional optionals;
  utils = import ../../utils.nix { inherit lib; };
  containerNumStr = if !builtins.isString containerNum then toString containerNum else containerNum;
  containerSubNumStr = if !builtins.isString containerSubNum then toString containerSubNum else containerSubNum;
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;
  defVolumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ] ++ optional makeLocaltimeVolume "/etc/localtime:/etc/localtime:ro";

  podName = "pod-${name}";
  containerIP = "10.88.${containerNumStr}.${containerSubNumStr}";

  nginxImport = if makeNginxConfig == false then [ ] else [
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

  systemd.services."create-pod-${name}" = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "${config.virtualisation.oci-containers.backend}-${name}.service" ];
    script = ''
      ${pkgs.podman}/bin/podman pod exists ${podName} || \
      ${pkgs.podman}/bin/podman pod create --name=${podName} --ip=${containerIP} --userns=keep-id \
        -p 127.0.0.1::${containerPortStr} -p 127.0.0.1::5432 -p 127.0.0.1::6379 ''
        + (builtins.concatStringsSep " " (builtins.map (it: "-p ${it}") additionalPorts))
      ;

  };

  virtualisation.oci-containers.containers = {
    "${name}" = utils.recursiveMerge [
      additionalContainerConfig
      {
        image = image;
        extraOptions = [ "--pod=${podName}" ];

        volumes = volumes ++ defVolumes;
        environment = { TZ = "Europe/Berlin"; } // environment;
        environmentFiles = environmentFiles;
      }
    ];

    "${name}-postgres" = mkIf (postgresEnvFile != null) {
      image = "postgres:15-alpine";
      extraOptions = [ "--pod=${podName}" ];

      environment = { POSTGRES_DB = name; };
      environmentFiles = [ postgresEnvFile ];
      volumes = [ "${dataDir}/postgresql/15:/var/lib/postgresql/data" ] ++ defVolumes;
      cmd = [ "-h" "127.0.0.1" ];
    };

    "${name}-mysql" = mkIf (mysqlEnvFile != null) {
      image = "linuxserver/mariadb:10.11.6";
      extraOptions = [ "--pod=${podName}" ];

      environment = {
        PUID = "400${containerNumStr}";
        PGID = "400${containerNumStr}";
        TZ = "Europe/Berlin";
        MYSQL_USER = name;
        MYSQL_DATABASE = name;
      };

      environmentFiles = [ mysqlEnvFile ];
      volumes = [
        "${dataDir}/mysql:/config"
        #        "/etc/mysql/custom.cnf:/config/custom.cnf"  # TODO: This is currently the only way to enable bind-address = 127.0.0.1. But when this is enabled, onlyoffice fails to connect to the database.
      ] ++ defVolumes;

    };

    "${name}-redis" = mkIf (redisEnvFile != null) {
      image = "redis:7.2.4-alpine";
      extraOptions = [ "--pod=${podName}" ];

      environmentFiles = [ redisEnvFile ];
      volumes = [ "${dataDir}/redis:/data" ] ++ defVolumes;
      cmd = [ "--bind" "127.0.0.1" ];

      # Currently, there is no password authentication.
      # This is not that big of an issue due to the fact that every container group (pod) has their own postgres / redis instance.
      # In the future, this assumption might change. Thus, we may want to work on implementing a password authentication.
      # The current issue holding us back is that the redis container doesn't want to substitute the environment variable. If that can be fixed, password authentication should be trivial.
      # cmd = [ "--requirepass" "$REDIS_PASSWORD" ];
    };
  };

  environment.etc = mkIf (mysqlEnvFile != null) {
    "mysql/custom.cnf".text = ''
      [mysqld]
      bind-address = "127.0.0.1"
      user=abc
    '';
  };

  systemd.tmpfiles.rules = optionals (postgresEnvFile != null) [
    "d ${dataDir}/postgresql/ 0750 70 70"
    "d ${dataDir}/postgresql/15/ 0750 70 70"
  ] ++ optionals (redisEnvFile != null) [
    "d ${dataDir}/redis/ 0750 999 999"
  ] ++ optionals (mysqlEnvFile != null) [
    "d ${dataDir}/mysql/ 0750 4001 4001"
  ];

}
