{ config, ... }:
let
  user = config.system.primaryUser;
in
{
  # Remote Login (Apple's built-in sshd), key-only and limited to the primary user.
  services.openssh = {
    enable = true;
    # Lands in /etc/ssh/sshd_config.d/100-nix-darwin.conf. sshd keeps the first
    # value it reads, and the Include sits at the top of /etc/ssh/sshd_config, so
    # these override its defaults (100-macos.conf only sets UsePAM/AcceptEnv/crypto).
    extraConfig = ''
      PermitRootLogin no
      AllowUsers ${user}

      # Public keys only: no passwords, no PAM keyboard-interactive prompts
      AuthenticationMethods publickey
      PubkeyAuthentication yes
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PermitEmptyPasswords no

      # Only keys declared in nix (users.users.<name>.openssh.authorizedKeys),
      # served by nix-darwin's AuthorizedKeysCommand; ~/.ssh/authorized_keys is ignored
      AuthorizedKeysFile none

      MaxAuthTries 3
      LoginGraceTime 30
      ClientAliveInterval 300
      ClientAliveCountMax 2

      X11Forwarding no
      AllowAgentForwarding no
      PermitTunnel no
    '';
  };

  # Public keys of the machines allowed to log in (one entry per client device)
  users.users.${user}.openssh.authorizedKeys.keys = [
  ];
}
