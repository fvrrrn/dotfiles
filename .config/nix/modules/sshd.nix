{...}: {
  services.openssh = {
    enable = true;
    ports = [22];
    # startWhenNeeded = true; # SSH daemon starts on-demand
    settings = {
      PasswordAuthentication = false;
      AllowUsers = ["fvrn"]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      Macs = [
        # For compatibility with passforios
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512"
      ];
    };
  };
}
