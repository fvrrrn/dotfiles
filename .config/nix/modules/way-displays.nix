{pkgs, ...}: let
  # The way-displays client namespaces its IPC socket by $XDG_VTNR, but NixOS's
  # sway drop-in only imports DISPLAY/WAYLAND_DISPLAY/SWAYSOCK into the systemd
  # user environment. Without this the daemon starts with XDG_VTNR unset and
  # `way-displays -g` from a terminal reports "way-displays not running".
  start = pkgs.writeShellScript "way-displays-start" ''
    session=$(${pkgs.systemd}/bin/loginctl show-user "$(${pkgs.coreutils}/bin/id -un)" -p Display --value)
    vtnr=$(${pkgs.systemd}/bin/loginctl show-session "$session" -p VTNr --value)
    [ -n "$vtnr" ] && export XDG_VTNR="$vtnr"
    exec ${pkgs.way-displays}/bin/way-displays
  '';
in {
  environment.systemPackages = [pkgs.way-displays];

  # Auto-arranges displays on hotplug (HDMI, USB-C DP-alt, dock) and on laptop
  # lid open/close. Rules live in ~/.config/way-displays/cfg.yaml, which the
  # daemon watches for changes — no restart needed after editing it.
  systemd.user.services.way-displays = {
    description = "way-displays automatic display management";
    documentation = ["man:way-displays(1)"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["sway-session.target"];
    unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${start}";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # way-displays reads the lid switch from /dev/input to know when the laptop
  # is closed; without this it silently loses lid handling.
  users.users.fvrn.extraGroups = ["input"];
}
