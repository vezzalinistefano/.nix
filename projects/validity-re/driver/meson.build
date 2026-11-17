# TOD driver build. `nix develop` provides libfprint-tod, glib, gusb and the toolchain;
# nothing here needs root until `install`.
#
#   meson setup build && ninja -C build
#   sudo install -Dm755 build/libfprint-tod-vcsfw.so /usr/lib/libfprint-2/tod-1/
#   sudo install -Dm644 60-libfprint-2-tod-vcsfw.rules /etc/udev/rules.d/
#
# A TOD driver is a bare shared object: no pkg-config name, no headers to install, and
# the ABI is whatever the libfprint-tod in the shell was built with. Keep the two in
# lockstep — a mismatch usually shows up as a crash inside fprintd, not a build error.
project('libfprint-tod-vcsfw', 'c', default_options: ['warning_level=3'])

tod = dependency('libfprint-2-tod-1')
glib = dependency('glib-2.0')
gusb = dependency('gusb')

shared_library(
  'fprint-tod-vcsfw',
  'vcsfw.c',
  dependencies: [tod, glib, gusb],
  install: false,
  # TOD drivers are dlopen()ed and must export fpi_tod_shared_driver_get_type()
  gnu_symbol_visibility: 'default',
)

install_data('60-libfprint-2-tod-vcsfw.rules', install_dir: '/etc/udev/rules.d')
