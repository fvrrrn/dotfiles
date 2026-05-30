{...}: {
  services.syncthing = {
    user = "fvrn";
    dataDir = "/home/fvrn/.config/syncthing";
    configDir = "/home/fvrn/.config/syncthing";
    enable = true;
    openDefaultPorts = true;
  };
}
