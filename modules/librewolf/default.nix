_: {
  # Firefox with privacy defaults and no telemetry
  programs.librewolf = {
    enable = true;
    policies.ExtensionSettings = {
      # Vimium: vim keys in the browser (f follows links, j/k scroll, H/L history, o opens a URL)
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
      };
    };
  };

  # stylix would need a named browser profile to theme; the browser keeps its own look
  stylix.targets.librewolf.enable = false;
}
