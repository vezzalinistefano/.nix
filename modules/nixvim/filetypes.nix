{ ... }:
{
  programs = {
    nixvim = {
      filetype = {
        pattern = {
          "%.gitlab%-ci%.ya?ml" = "yaml.gitlab";
        };
      };
    };
  };
}
