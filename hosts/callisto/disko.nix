# Disk layout, applied by nixos-anywhere at install time (it WIPES `device`).
# GPT: 1G EFI system partition, the rest one LUKS volume holding an ext4 root.
{
  disko.devices.disk.main = {
    type = "disk";
    # Check with `lsblk` on the machine before installing: a T480 has an NVMe
    # slot (/dev/nvme0n1) and a SATA bay (/dev/sda), and either can hold the system disk.
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
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Only read while formatting: nixos-anywhere uploads the passphrase here
            # (--disk-encryption-keys /tmp/luks.key <local file>). Later boots ask for it.
            passwordFile = "/tmp/luks.key";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
