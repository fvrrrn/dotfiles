{
  pkgs,
  inputs,
  ...
}: {
  boot.loader.systemd-boot.configurationLimit = 5;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libGL
      libGLX
      libglvnd
      stdenv.cc.cc.lib
      zlib
      fontconfig
      freetype
      libx11
      libgpg-error
      krb5
      e2fsprogs
    ];
  };

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
    extraGroups = ["networkmanager" "wheel" "dialout"];
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

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  services.displayManager.ly = {
    enable = true;
    settings = {
      # "matrix" (CMatrix) | "doom" (PSX DOOM fire) | "colormix" | "none"
      animation = "matrix";
      clock = "%H:%M";
    };
  };

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # expose sway-nvidia as a selectable session in GDM
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "sway-nvidia-session" {
        passthru.providedSessions = ["sway-nvidia"];
      } ''
        mkdir -p $out/share/wayland-sessions
        cat > $out/share/wayland-sessions/sway-nvidia.desktop <<EOF
        [Desktop Entry]
        Name=Sway (NVIDIA)
        Exec=/run/current-system/sw/bin/sway-nvidia
        Type=Application
        DesktopNames=sway
        EOF
      '')
  ];

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
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    MaxRetentionSec = "30day";
  };

  systemd.tmpfiles.rules = [
    "d /home/tunneller/.ssh 0700 tunneller tunneller -"
  ];

  environment.systemPackages = with pkgs; [
    kitty
    (pkgs.callPackage ./pkgs/dfzf.nix {})
    (pkgs.callPackage ./pkgs/dfzf-search.nix {})

    sops
    ssh-to-age

    autossh
    sshfs
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    lazygit
    bluetuith

    wget
    zathura # pdf reader

    python3
    uv
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

    nicotine-plus
    telegram-desktop

    gnumake
    unzip

    transmission_4-qt
    vlc

    lua-language-server
    ty # python type-checker and language server (rust, fast)
    ruff # python linter and formatter
    nil # nix lsp
    alejandra # nix formatter
    jq # json formatter
    stylua # lua formatter

    (pkgs.pass.withExtensions (exts: [exts.pass-otp]))
    pinentry-curses

    tree
    fzf
    gh

    # binary / file inspection
    file # identify a file's type from its magic bytes
    unixtools.xxd # hex dump, and -r to patch binaries back from hex
    unixtools.hexdump # hexdump(1); complements coreutils' od
    binwalk # find embedded files/filesystems inside firmware blobs
    exiftool # read/strip metadata from media and documents
    poppler-utils # pdftotext/pdfinfo/pdftoppm: inspect and extract PDFs
    usbutils # lsusb: identify USB devices by vendor/product id
    ffmpeg # full CLI; ffmpegthumbnailer above only does thumbnails
    p7zip # 7z/rar/etc, for archives unzip cannot open

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

    # SUDO_ASKPASS helper: lets sudo prompt via wmenu when there is no TTY
    # (e.g. commands run by Claude Code). $1 is the prompt text sudo passes in,
    # so the dialog shows what is being escalated.
    (pkgs.writeShellScriptBin "wmenu-askpass" ''
      exec ${pkgs.wmenu}/bin/wmenu -P -p "''${1:-Password:}" < /dev/null
    '')

    # cursor/icon theme referenced by XCURSOR_THEME below
    adwaita-icon-theme

    vscodium-fhs
    obsidian

    remmina
    (pkgs.appimageTools.wrapType2 {
      pname = "rustdesk";
      version = "1.4.9";
      src = pkgs.fetchurl {
        url = "https://github.com/rustdesk/rustdesk/releases/download/1.4.9/rustdesk-1.4.9-x86_64.AppImage";
        sha256 = "05w2wbafs3v2wyzhfywg1rlsqlhrk9fa2s16pvp1g67jlihcs0kr";
      };
    })

    yt-dlp
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

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
  hardware.steam-hardware.enable = true;

  security.sudo.extraRules = [
    {
      users = ["fvrn"];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start sing-box";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop sing-box";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart sing-box";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl status sing-box";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}
