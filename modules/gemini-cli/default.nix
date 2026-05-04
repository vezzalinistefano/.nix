{ ... }:

{
  programs = {
    gemini-cli = {
      enable = true;
      settings = {
        privacy = {
          usageStatisticsEnabled = false;
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
        general = {
          preferredEditor = "nvim";
          previewFeatures = true;
          vimMode = true;
        };
      };
    };
  };
}
