{
  pkgs,
  hostname,
  inputs,
  ...
}: {
  boot.loader.systemd-boot.configurationLimit = 5;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  users.users.fvrn = {
    isNormalUser = true;
    description = "Boris Chernyshov";
    extraGroups = ["networkmanager" "wheel"];
  };

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway-nvidia";
        user = "fvrn";
      };
    };
  };

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
  services.dbus.packages = [pkgs.networkmanager];

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.interception-tools = {
    enable = true;
    plugins = [
      pkgs.interception-tools-plugins.dual-function-keys
    ];
    udevmonConfig = let
      dualFunctionKeysConfig = builtins.toFile "dual-function-keys.yaml" ''
        MAPPINGS:
          - KEY: KEY_CAPSLOCK
            TAP: KEY_ESC
            HOLD: KEY_LEFTCTRL
            HOLD_START: BEFORE_CONSUME_OR_RELEASE
          - KEY: KEY_SPACE
            TAP: KEY_SPACE
            HOLD: KEY_LEFTMETA
            HOLD_START: BEFORE_CONSUME_OR_RELEASE
      '';
    in ''
      - JOB: |
          ${pkgs.interception-tools}/bin/intercept -g $DEVNODE \
            | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c ${dualFunctionKeysConfig} \
            | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_SPACE]
    '';
  };

  programs.git.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
  ];

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland for Firefox
    QT_QPA_PLATFORM = "wayland"; # Use Wayland for Qt apps
    GDK_BACKEND = "wayland,x11"; # Use Wayland for GTK apps, fallback to X11 if needed
    XDG_SESSION_TYPE = "wayland";
    # XDG_CURRENT_DESKTOP = "sway";
    # XDG_SESSION_DESKTOP = "sway";
    CLUTTER_BACKEND = "wayland";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  systemd.tmpfiles.rules = [
    "d /home/tunneller/.ssh 0700 tunneller tunneller -"
  ];

  environment.systemPackages = with pkgs; [
    sops
    autossh
    sshfs
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.eden-flake.packages.${pkgs.stdenv.hostPlatform.system}.eden
    lazygit
    bluetuith

    wget
    zathura # pdf reader

    python3
    ungoogled-chromium
    pavucontrol
    fastfetch
    ripgrep
    fd
    yazi
    ffmpegthumbnailer
    poppler
    imagemagick
    btop
    bat

    spotify
    telegram-desktop

    gnumake
    unzip

    transmission_4-qt
    vlc

    lua-language-server
    basedpyright # python type-checker
    ruff # python linter and formatter
    nil # nix lsp
    alejandra # nix formatter
    jq # json formatter
    stylua # lua formatter

    (pkgs.pass.withExtensions (exts: [exts.pass-otp]))
    pinentry-curses

    tree
    fzf

    # sway related
    # @see https://wiki.nixos.org/wiki/Sway
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    gammastep
    wf-recorder
    wdisplays
    mako # notification system developed by swaywm maintainer
    (pkgs.writeShellScriptBin "sway-nvidia" ''
      exec ${pkgs.sway}/bin/sway --unsupported-gpu "$@"
    '')

    vscodium-fhs
    (vscode.overrideAttrs (old: rec {
      version = "1.108.0";
      src = fetchurl {
        name = "VSCode_${version}_linux-x64.tar.gz";
        url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
        sha256 = "02fzc7js802iydf1rkrxarn34f15nmqnrg8h6z0jv1y5y46rsk6v";
      };
    }))
    code-cursor
    obsidian

    remmina

    claude-code

    yt-dlp
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.amnezia-vpn.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [22]; # Allow SSH only
  networking.firewall.allowedUDPPorts = []; # No UDP services exposed
  networking.hostName = hostname; # Define your hostname.

  networking = {
    # Point DNS queries to the local dnscrypt-proxy service
    nameservers = ["127.0.0.1" "::1"];

    # Prevent NetworkManager from managing resolv.conf
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };

    # If using dhcpcd instead of NetworkManager:
    # dhcpcd.extraConfig = "nohook resolv.conf";
  };

  # Disable systemd-resolved (it conflicts)

  networking.resolvconf.dnsExtensionMechanism = false;
  services.resolved.enable = true;

  # Enable dnscrypt-proxy
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      ipv6_servers = true;
      server_names = ["google" "cloudflare" "quad9-doh"];
      listen_addresses = ["127.0.0.1:53" "[::1]:53"];
      require_dnssec = true;
      # only use DoH servers
      doh_servers = true;

      # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
      query_log.file = "/var/log/dnscrypt-proxy/query.log";
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = ["fvrn"];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}
