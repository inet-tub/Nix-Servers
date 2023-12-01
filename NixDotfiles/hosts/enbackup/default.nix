{ config, pkgs, lib, inputs, modulesPath, ... }: {
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

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "nvme"
    "ahci"
    "ehci_pci"
    "megaraid_sas"
    "uas"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
    "ata_piix"
    "floppy"
    "kvm-intel"
    "xhci_pci"
    "uhci_hcd"
    "hpsa"
  ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=68719476736"
    "zfs.zfs_arc_min=12884901888"
    "zfs.zfs_arc_meta_limit=12884901888"
  ];

  networking = {
    hostName = "enbackup";
    hostId = "abcd1234";
  };
  time.timeZone = "Europe/Berlin";

  # import preconfigured profiles
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/hardened.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
  ];
}
