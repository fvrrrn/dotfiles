{
  pkgs,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;

    # sing-box's tun inbound is IPv4-only (address = 172.19.0.1/30, no
    # inet6_address), so IPv6 bypasses the tunnel and goes out direct. The
    # upstream v6 path blackholes (SYN-SENT, no reply), which stalls anything
    # that resolves AAAA first. Turn v6 off so it never gets tried.
    enableIPv6 = false;

    firewall = {
      enable = true;
      # 2234: Nicotine+ (Soulseek) listening port, must accept inbound peer
      # connections or transfers fall back to indirect and time out.
      allowedTCPPorts = [22 2234];
      allowedUDPPorts = [];
    };
  };

  services.dbus.packages = [pkgs.networkmanager];

  programs.amnezia-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    dnsutils
  ];
}
