{ lib, inputs, ... }:
{
  # Light variant of the desktop theme (see modules/stylix). Switch:
  #   sudo /run/current-system/specialisation/light/bin/switch-to-configuration switch
  # back: sudo /run/current-system/bin/switch-to-configuration switch
  # A specialisation is an extendModules variant: the parent modules are still
  # evaluated, so mkForce makes it explicit that this variant wins.
  specialisation.light.configuration = {
    home-manager.users.sv.stylix = {
      base16Scheme = lib.mkForce "${inputs.self}/modules/stylix/schemes/svn-aaa-light.yaml";
      polarity = lib.mkForce "light";
    };
  };
}
