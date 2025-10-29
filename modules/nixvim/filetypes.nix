{ ... }:
{
  programs = {
    nixvim = {
      filetype = {
        "yaml.gitlab" = {
          pattern = [
            "%.gitlab%-ci%.ya?ml"
          ];
        };
      };
    };
  };
}
