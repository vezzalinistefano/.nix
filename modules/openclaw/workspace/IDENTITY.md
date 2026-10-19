# OpenClaw Workspace Identity

Unique identifiers and metadata for this workspace.

## Workspace Metadata

**Workspace ID**: jose-local-macos  
**Owner**: Stefano Vezzalini  
**Created**: 2026-06-18  
**Environment**: Development (local macOS)  

## Connectivity

- **Gateway Mode**: Local
- **Network**: Localhost only (no public exposure)
- **Channels**: None (headless mode)

## Security

- Bot token: Not applicable (headless mode)
- API keys: Bifrost virtual key from `~/.secrets/openclaw/bifrost.key`
- Gateway auth: Environment variable `OPENCLAW_GATEWAY_TOKEN`

## Integration

- **OS**: macOS (aarch64-darwin)
- **Init System**: launchd
- **Config Manager**: nix-darwin + home-manager
- **Declarative**: Fully Nix-managed
