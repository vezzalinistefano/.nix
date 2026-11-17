{ pkgs, ... }:
{
  # Mount removable drives (USB sticks, phones, the SD card) under /run/media when they
  # are plugged in, and offer to unlock/format them from the tray icon (tray only shows
  # up while there is something to show). Needs services.udisks2 on the host.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings.program_options.udisks_version = 2;
  };

  # The module starts the daemon but does not put the CLI on PATH: `udiskie-mount -l`,
  # `udiskie-umount -a` and friends are the useful part when a drive refuses to go.
  home.packages = [ pkgs.udiskie ];
}
