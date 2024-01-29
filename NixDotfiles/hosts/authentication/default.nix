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
      enable = true;
      flags = "-k -p --utc";

      # How many snapshots to keep
      weekly = 7;
      monthly = 120;
    };
  };

  system.stateVersion = "23.11";

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
  ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=12884901888"
    "zfs.zfs_arc_min=4294967296"
    "zfs.zfs_arc_meta_limit=8589934592"
  ];

  networking = {
    hostName = "authentication";
    hostId = "abcd1234";
  };

  time.timeZone = "Europe/Berlin";

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./networking.nix
    ./services.nix
    ./secrets.nix
  ];
}
