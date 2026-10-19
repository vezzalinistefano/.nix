# OpenClaw Tools

Installed tools and plugins for this OpenClaw instance.

## Available Tools

Currently: None (headless mode)

## Future Tool Plugins

When ready to add capabilities, edit `modules/openclaw/default.nix`:

```nix
programs.openclaw.runtimePlugins = [
  # Examples:
  # "screenshot"
  # "applescript"
  # "shell-exec"
  # "github"
];
```

Then run: `home-manager switch --flake /private/etc/nix-darwin`

## Runtime Plugin Installation

In nix-openclaw, plugins are declared in Nix, not installed at runtime. This ensures:

- Deterministic builds
- Version pinning via flake.lock
- Zero state drift
- Instant rollback
