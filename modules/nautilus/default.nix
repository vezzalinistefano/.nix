{ pkgs, ... }:
{
  # GNOME Files: a browser-shaped, actively developed file manager that picks up the
  # Adwaita icons and the stylix colours like the rest of the GTK apps here.
  home.packages = [ pkgs.nautilus ];

  # Folders open here, including the ones udiskie mounts from removable media
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "org.gnome.Nautilus.desktop";
    "application/x-gnome-saved-search" = "org.gnome.Nautilus.desktop";
  };
}
