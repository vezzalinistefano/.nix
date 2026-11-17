{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fingerprint-auth;

  # Packages from the fingerprint-sensor flake (see flake.nix). They are re-called with
  # the system's own pkgs instead of the flake's module: upstream's module builds them
  # against a plain `import nixpkgs`, which misses overlays and, more importantly, the
  # buildPythonPackage API of the current nixpkgs (it still declares a `format`).
  src = inputs.fingerprint-sensor;
  python = pkgs.python312Packages;

  # Upstream's package still declares the removed `format = "setuptools"`, which current
  # nixpkgs rejects. Feed pyproject/build-system in through its own buildPythonPackage
  # rather than forking the file.
  python' = python // {
    buildPythonPackage =
      attrs:
      python.buildPythonPackage (
        attrs
        // {
          pyproject = true;
          build-system = attrs.build-system or [ python.setuptools ];
        }
      );
  };
  python-validity =
    (pkgs.callPackage "${src}/pkgs/python-validity" { python3Packages = python'; }).overrideAttrs
      (old: {
        # upstream's setup.py still says 0.13 while the tree is tagged 0.14; the metadata
        # check phase fails on the mismatch
        postPatch = (old.postPatch or "") + ''
          substituteInPlace setup.py --replace "version='0.13'" "version='0.14'"
          # the shipped udev rule calls /bin/systemctl, which the udev rule check cannot
          # resolve in the build sandbox
          substituteInPlace debian/python3-validity.udev \
            --replace "/bin/systemctl" "${pkgs.systemd}/bin/systemctl"
        '';
      });
  open-fprintd = pkgs.open-fprintd;
  calib-data = pkgs.callPackage "${src}/pkgs/calib-data" {
    calib-data-file =
      if cfg.calibDataFile == null then ./calib-data.placeholder.bin else cfg.calibDataFile;
  };
  tod-driver = pkgs.callPackage "${src}/pkgs/libfprint-2-tod1-vfs0090-bingch" {
    inherit calib-data python-validity;
  };

  sleepTargets = [
    "suspend.target"
    "hibernate.target"
    "hybrid-sleep.target"
    "suspend-then-hibernate.target"
  ];

  # one attempt, then the password
  fingerprintSettings = {
    max-tries = 1;
    timeout = 10;
  };
in
{
  # Fingerprint authentication for the Synaptics 06cb:009a reader in the ThinkPad T480.
  # libfprint 1.94 has no driver for this chip (it lists the USB ID as unsupported), so
  # this module supplies either python-validity with open-fprintd or a fork of the
  # vfs0090 TOD driver that plugs into the normal fprintd.
  #
  # Every stack keeps the password as the next step (pam_fprintd is `sufficient` with one
  # try and a 10 s timeout, hyprlock falls back to its input field), so a sensor that stops
  # reading never locks you out. To drop fingerprint auth entirely: set `enable = false`,
  # run `nrs`, or boot the previous generation. See docs/wiki/nixos-host-setup.md

  options.services.fingerprint-auth = {
    enable = lib.mkEnableOption "fingerprint authentication (Synaptics 06cb:009a)";

    backend = lib.mkOption {
      type = lib.types.enum [
        "python-validity"
        "libfprint-tod"
      ];
      default = "python-validity";
      description = ''
        Driver stack. `python-validity` talks to the chip through its own daemon and is
        the only one that can enroll; it replaces fprintd's daemon with open-fprintd.
        `libfprint-tod` is a TOD driver for the normal fprintd: fewer moving parts and it
        integrates with the usual fprintd tooling, but it can only verify, not enroll, and
        needs the calibration data `python-validity` extracts while enrolling.
      '';
    };

    calibDataFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        The `calib-data.bin` that a python-validity enrollment writes to
        /var/lib/python-validity. Required for the `libfprint-tod` backend (it is
        compiled in), unused with `python-validity`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.backend != "libfprint-tod" || cfg.calibDataFile != null;
        message = "services.fingerprint-auth.backend = \"libfprint-tod\" needs calibDataFile.";
      }
    ];

    # fprintd-enroll, fprintd-list, fprintd-verify. Only the tooling: its daemon is
    # replaced by open-fprintd in the python-validity backend.
    environment.systemPackages = [
      pkgs.fprintd
    ]
    ++ lib.optional (cfg.backend == "python-validity") python-validity;

    # Ask for a finger first, then fall back to the password after one try / 10 seconds
    security.pam.services =
      lib.genAttrs
        [
          "sudo"
          "polkit-1"
          "login"
        ]
        (_: {
          fprintAuth = true;
          rules.auth.fprintd.settings = fingerprintSettings;
        })
      // {
        # greetd turns the default rules off and just substacks `login`, so fprintAuth is
        # ignored there: the rule goes in by hand, ahead of that substack.
        greetd.rules.auth.fprintd = {
          control = "sufficient";
          modulePath = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
          settings = fingerprintSettings;
          order = config.security.pam.services.greetd.rules.auth.login.order - 10;
        };
      };

    # Enabling the fprintd daemon here conflicts with open-fprintd: both claim the
    # net.reactivated.Fprint name on the bus.
    services.fprintd = lib.mkIf (cfg.backend == "libfprint-tod") {
      enable = true;
      tod = {
        enable = true;
        driver = tod-driver;
      };
    };

    # python-validity: the sensor daemon plus the fprintd-compatible service on top of it
    systemd.packages = lib.mkIf (cfg.backend == "python-validity") [
      python-validity
      open-fprintd
    ];
    services.dbus.packages = lib.mkIf (cfg.backend == "python-validity") [
      python-validity
      open-fprintd
    ];
    services.udev.packages = lib.mkIf (cfg.backend == "python-validity") [ python-validity ];

    # The sensor stays busy after a suspend without open-fprintd's resume/suspend helpers
    # (upstream's workaround). systemd.packages only links units, it does not act on their
    # [Install] sections, so the enablement is spelled out here.
    systemd.services = lib.mkIf (cfg.backend == "python-validity") {
      python3-validity.wantedBy = [ "multi-user.target" ];
      open-fprintd-resume.wantedBy = sleepTargets;
      open-fprintd-suspend.wantedBy = sleepTargets;
    };
  };
}
