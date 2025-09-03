{ ... }:
{
  programs = {
    kubecolor = {
      enable = true;
      enableAlias = true;
      enableZshIntegration = true;
    };
    k9s = {
      enable = true;
    };
  };
}
