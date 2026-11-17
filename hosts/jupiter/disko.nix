# Disk layout, applied by nixos-anywhere at install time (it WIPES `device`).
# GPT: 1G EFI system partition, the rest one ext4 root.
#
# jupiter is a physical server that boots in UEFI mode, so systemd-boot lives on
# the ESP. `device` is the NVMe that today holds Proxmox: the Samsung SATA disk
# (/dev/sda) has a Windows install on it and must stay untouched.
#
# No LUKS on purpose: the server has to come back from a reboot without a
# passphrase typed at the console. For an encrypted root, replace the root
# partition with the luks block from hosts/callisto/disko.nix, or use TPM2.
{
  disko.devices.disk.main = {
    type = "disk";
    # Confirm with `lsblk` before installing: the Proxmox host uses /dev/nvme0n1.
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
