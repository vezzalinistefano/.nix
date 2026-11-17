{ lib, pkgs, ... }:
let
  # Left click on a banner should open the app that sent it:
  #   1. if the notification carries a default action, invoke it — mako hands the
  #      client an xdg-activation token, so the app opens *and* takes focus;
  #   2. otherwise (plain `notify-send` from a script, mostly) raise the sender's
  #      window: match the words of its app name / desktop entry against the
  #      Hyprland window class and title;
  #   3. nothing to open, so leave the banner where it is.
  openApp = pkgs.writeShellScript "mako-open" ''
    id="''${1:-}"
    [ -n "$id" ] || exit 0

    json="$(${pkgs.mako}/bin/makoctl list -j 2>/dev/null)" || exit 0
    field() {
      printf '%s' "$json" | ${pkgs.jq}/bin/jq -r --argjson id "$id" \
        ".[] | select(.id == \$id) | ($1 // empty)"
    }

    if [ -n "$(field '.actions.default')" ]; then
      exec ${pkgs.mako}/bin/makoctl invoke -n "$id" default
    fi

    command -v hyprctl >/dev/null 2>&1 || exit 0
    clients="$(hyprctl -j clients 2>/dev/null)" || exit 0

    for word in $(printf '%s %s' "$(field '.app_name')" "$(field '.desktop_entry')" |
      tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' ' '); do
      [ ''${#word} -ge 4 ] || continue
      case "$word" in
        desktop | application | notification | client | system | linux) continue ;;
      esac
      address="$(printf '%s' "$clients" | ${pkgs.jq}/bin/jq -r --arg w "$word" '
        [.[] | select(((.class // "") + " " + (.title // "")) | ascii_downcase | contains($w))]
        | sort_by(.focusHistoryID) | .[0].address // empty')"
      if [ -n "$address" ]; then
        hyprctl dispatch focuswindow "address:$address" >/dev/null
        ${pkgs.mako}/bin/makoctl dismiss -n "$id" >/dev/null 2>&1
        exit 0
      fi
    done
  '';
in
{
  # Desktop notifications, themed by stylix (colours, opacity). The shape is ours:
  # rounded like the rest of the desktop (hyprland's rounding), padded so the text and
  # icon breathe, and stacked in the top-right corner under the bar.
  services.mako = {
    enable = true;
    settings = {
      # stylix picks the family and 10pt from `fonts.sizes.popups`, which is too small
      # on the 14" 1080p panel. Noto Sans has a taller x-height than IBM Plex, so it
      # reads better at a glance; mkForce because stylix assigns `font` unconditionally.
      font = lib.mkForce "Noto Sans 13";
      # Wider and roomier to match the bigger type
      width = 400;
      padding = 18;
      max-icon-size = 48;

      anchor = "top-right";
      layer = "overlay";
      margin = 10;
      border-size = 2;
      border-radius = 10;
      default-timeout = 6000;
      max-visible = 3;
      # Let the urgency heading stand out from the body
      format = "<b>%s</b>\\n%b";
      markup = 1;
      # Group repeated notifications from one app instead of stacking every one
      group-by = "app-name";
      # App icons, scaled square with the same rounding as the frame. mako always
      # searches /usr/share/{icons/hicolor,pixmaps}, which NixOS does not have.
      icons = 1;
      icon-border-radius = 8;
      icon-path = "/run/current-system/sw/share/icons/hicolor:/run/current-system/sw/share/pixmaps";
      # Click to open, right click to dismiss (mako's default for the left button is
      # already invoke-default-action; the wrapper adds the focus fallback)
      on-button-left = "exec ${openApp} \"$id\"";
      on-button-right = "dismiss";
      "urgency=critical" = {
        # Errors stay until dismissed
        default-timeout = 0;
      };
    };
  };
}
