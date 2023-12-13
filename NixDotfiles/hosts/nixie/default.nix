{ config, modulesPath, ... }: {
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "bootDevices_placeholder" ];
      immutable = false;
      removableEfi = true;
      luks.enable = false;

      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
  };

  boot.zfs.forceImportRoot = false;
  services.zfs = {
    autoSnapshot = {
      enable = false;
      flags = "-k -p --utc";
      weekly = 7; # How many snapshots to keep
      monthly = 48;
    };
  };

  system.stateVersion = "23.05";

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
    "megaraid_sas"
    "ata_piix"
    "kvm-intel"
    "xhci_pci"
  ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=68719476736"
    "zfs.zfs_arc_min=12884901888"
    "zfs.zfs_arc_meta_limit=12884901888"
  ];

  networking = {
    hostName = "nixie";
    hostId = "abcd1234";
  };

  time.timeZone = "Europe/Berlin";

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./networking.nix
    ./services.nix
  ];
}
