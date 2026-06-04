{
  pkgs,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      allowedUDPPorts = [];
    };
  };

  services.dbus.packages = [pkgs.networkmanager];

  programs.amnezia-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    dnsutils
  ];
}
