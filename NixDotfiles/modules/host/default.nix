{ config, lib, pkgs, ... }:

let
  cfg = config;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  inherit (builtins) head toString map tail;
in
{
  options.host = mkOption {
    description = "Host configuration";

    type = types.submodule { options = {
      name = mkOption {
        description = "Specify the host name";
        type = types.str;
      };

      id = mkOption {
        description = "Specify the host id";
        type = types.str;
      };

      bootDevices = mkOption {
        description = "Specify boot devices";
        type = types.nonEmptyListOf types.str;
      };

      additionalKernelModules = mkOption {
        description = "Additional kernel modules to load";
        type = types.listOf types.str;
        default = [];
      };

      zfsAutoSnapshot = mkOption {
        description = "Enable zfs-auto-snapshot";
        default = null;

        type = types.submodule { options = {
          enable = mkOption {
            default = false;
            type = types.bool;
            description = "Enable zfs-auto-snapshot";
          };

          hourly = mkOption {
            default = 0;
            type = types.int;
            description = "Number of hourly auto-snapshots that you wish to keep.";
          };

          daily = mkOption {
            default = 7;
            type = types.int;
            description = "Number of daily auto-snapshots that you wish to keep.";
          };

          weekly = mkOption {
            default = 4;
            type = types.int;
            description = "Number of weekly auto-snapshots that you wish to keep.";
          };

          monthly = mkOption {
            default = 12;
            type = types.int;
            description = "Number of monthly auto-snapshots that you wish to keep.";
          };
        };};
      };

      zfsArc = mkOption {
        description = "Set the ZFS ARC limits";

        type = types.submodule { options = {
          minGB = mkOption {
            default = 4;
            type = types.int;
            description = "Minimum size of the ARC in Gigabytes";
          };

          maxGB = mkOption {
            default = 8;
            type = types.int;
            description = "Maximum size of the ARC in Gigabytes";
          };

          metaGB = mkOption {
            default = 4;
            type = types.int;
            description = "Maximum size of the ARC metadata in Gigabytes";
          };
        };};
      };

      zfsMetrics = mkOption {
        description = "Enable ZFS metrics";
        type = types.bool;
        default = false;
      };

      networking = mkOption {
        description = "Enable networking";
        type = types.submodule { options = {

          ip = mkOption {
            type = types.str;
            description = "IP address of the host";
          };

          location = mkOption {
            type = types.enum [ "en" "mar" ];
            description = "Location of the host";
          };

          networkRange = mkOption {
            type = types.enum [ "ennet" "birdcage" "dmz" ];
            description = "Network range to be used";
          };

          interface = mkOption {
            type = types.str;
            description = "Interface to be used";
          };
          # TODO: Add second interface for admin network

          firewallAllowedTCPPorts = mkOption {
            type = types.listOf types.int;
            description = "Ports to be allowed in the firewall";
            default = [ 22 80 443 ];
          };

          firewallAllowedUDPPorts = mkOption {
            type = types.listOf types.int;
            description = "Ports to be allowed in the firewall";
            default = [ ];
          };

          domainName = mkOption {
            type = types.str;
            description = "Domain name to be used";
            default = "inet.tu-berlin.de";
          };

          containerHostIP = mkOption {
            type = types.str;
            description = "IP address of the container host";
            default = "192.168.7.1";
          };

        };};
      };
    };};
  };


  config = {
    assertions = [
      { assertion = config.networking.defaultGateway.address != ""; }
      { assertion = config.networking.defaultGateway6.address != ""; }
    ];

    zfs-root.boot.bootDevices = config.host.bootDevices;
    boot.zfs.forceImportRoot = false;

    services.zfs.autoSnapshot = {
      enable = config.host.zfsAutoSnapshot.enable;
      flags = "-k -p --utc";

      frequent = 0;
      hourly = config.host.zfs-auto-snapshot.hourly;
      daily = config.host.zfs-auto-snapshot.daily;
      weekly = config.host.zfs-auto-snapshot.weekly;
      monthly = config.host.zfs-auto-snapshot.monthly;
    };

    boot.kernelParams = [
      "zfs_arc_min=${toString (config.host.zfsArc.minGB * 1073741824)}"
      "zfs_arc_max=${toString (config.host.zfsArc.maxGB * 1073741824)}"
      "zfs_arc_meta_limit=${toString (config.host.zfsArc.metaGB * 1073741824)}"
    ];

    boot.initrd.availableKernelModules = [
      # "Normal" disk Support
      "sd_mod"
      "sr_mod"
      "nvme"
      "ahci"

      # QEMU
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"

      # USB
      "uas"
      "usb_storage"
      "usbhid"

      # Legacy Server Modules
      "ehci_pci"
      "ata_piix"
      "kvm-intel"
      "xhci_pci"

      # Legacy RAID modules
      "megaraid_sas"
      "hpsa"
    ] ++ config.host.additionalKernelModules;

    time.timeZone = "Europe/Berlin";

    networking = {
      hostName = config.host.name;
      hostId = config.host.id;
      useDHCP = false;

      nameservers = [ "130.149.220.253" "130.149.152.187" ];
      search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

      defaultGateway = {
        interface = config.host.networking.interface;
        address =
          if config.host.networking.networkRange == "ennet" then
            "130.149.152.129"
          else if config.host.networking.networkRange == "birdcage" then
            ""  # TODO
          else if config.host.networking.networkRange == "dmz" then
            "130.149.220.126"
          else
            ""
          ;
      };

      defaultGateway6 = {
        interface = config.host.networking.interface;
        address = "fe80::1";
      };

      interfaces."${config.host.networking.interface}" = {

        ipv4.addresses = [{
          address = config.host.networking.ip;
          prefixLength = 25;
        }];

        ipv6.addresses = [{
          address = "2001:638:809:ff${if config.host.networking.networkRange == "ennet" then
            "20"
          else if config.host.networking.networkRange == "birdcage" then
            ""  # TODO
          else if config.host.networking.networkRange == "dmz" then
            "11"
          else
            ""}:${lib.replaceStrings [ "." ] [ ":" ] config.host.networking.ip}";
          prefixLength = 64;
        }];
      };

      firewall = {
        enable = true;
        allowedTCPPorts = config.host.networking.firewallAllowedTCPPorts;
        allowedUDPPorts = config.host.networking.firewallAllowedUDPPorts;
      };

      # For the containers
      nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = config.host.networking.interface;
      };

    };
  };
}