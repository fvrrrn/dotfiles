{
  config,
  pkgs,
  ...
}: {
  users.users.tunnel = {
    isSystemUser = true;
    group = "tunnel";
    home = "/home/tunnel";
    createHome = true;
    shell = "${pkgs.shadow}/bin/nologin";
  };
  users.groups.tunnel = {};

  systemd.services.autossh-soulseek = {
    description = "autossh reverse tunnel for Soulseek port 2234";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    environment.AUTOSSH_GATETIME = "0";

    serviceConfig = {
      Type = "simple";
      User = "tunnel";
      Restart = "always";
      RestartSec = "10";
      # The -R target must be the LAN address, not localhost: Nicotine+ binds
      # its listening socket to the interface address (192.168.1.11:2234), so
      # forwarding to 127.0.0.1:2234 gets connection-refused and every inbound
      # peer connection dies at this last hop. Note the VPS still accepts the
      # TCP handshake on :2234 regardless, so port tests pass either way.
      # Keep a DHCP reservation for 192.168.1.11 or this breaks on lease change.
      ExecStart = pkgs.writeShellScript "autossh-soulseek" ''
        exec ${pkgs.autossh}/bin/autossh \
          -M 0 \
          -N \
          -o ExitOnForwardFailure=yes \
          -o ServerAliveInterval=60 \
          -o ServerAliveCountMax=3 \
          -o StrictHostKeyChecking=accept-new \
          -o UserKnownHostsFile=/home/tunnel/.ssh/known_hosts \
          -i /home/tunnel/.ssh/id_ed25519 \
          -p 4455 \
          -R 2234:192.168.1.11:2234 \
          tunnel@$(cat ${config.sops.secrets.singbox_server.path})
      '';
    };
  };
}
