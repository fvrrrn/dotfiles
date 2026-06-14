{
  pkgs,
  lib,
  inputs,
  ...
}: {
  boot.loader.systemd-boot.configurationLimit = 5;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.nix-ld = {
    enable = true;
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

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  programs.dconf.profiles.user.databases = [{
    locks = [
      "/org/gnome/desktop/interface/cursor-theme"
      "/org/gnome/desktop/interface/icon-theme"
      "/org/gnome/desktop/interface/cursor-size"
    ];
    settings = {
      # Enable PaperWM declaratively + recommended mutter settings
      "org/gnome/shell" = {
        "enabled-extensions"     = [ "paperwm@paperwm.github.com" ];
        "disable-user-extensions" = false;
      };
      "org/gnome/mutter" = {
        "edge-tiling"          = false;
        "attach-modal-dialogs" = false;
        "workspaces-only-on-primary" = false;
      };
      "org/gnome/desktop/interface" = {
        "enable-animations" = false;
        "cursor-theme"      = "Adwaita";
        "icon-theme"        = "Adwaita";
        "cursor-size"       = lib.gvariant.mkInt32 24;
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        "delay"           = lib.gvariant.mkUint32 200;
        "repeat-interval" = lib.gvariant.mkUint32 20;
      };
      # PaperWM appearance and behaviour
      "org/gnome/shell/extensions/paperwm" = let
        u = lib.gvariant.mkUint32;
      in {
        "winprops"                       = [ ''{"wm_class":".*","preferredWidth":"100%"}'' ];
        "window-gap"                     = u 0;
        "horizontal-margin"              = u 0;
        "vertical-margin"                = u 0;
        "vertical-margin-bottom"         = u 0;
        "selection-border-size"          = u 1;
        "selection-border-radius-top"    = u 0;
        "selection-border-radius-bottom" = u 0;
      };
      "org/gnome/shell/extensions/gesture-inhibitor" = {
        "workspace-switch" = false;
      };
      # PaperWM: focus movement (h=left j=down k=up l=right)
      "org/gnome/shell/extensions/paperwm/keybindings" = {
        "switch-left"  = [ "<Super>h" ];
        "switch-right" = [ "<Super>l" ];
        "switch-down"  = [ "<Super>j" ];
        "switch-up"    = [ "<Super>k" ];
        "move-left"    = [ "<Super><Shift>h" ];
        "move-right"   = [ "<Super><Shift>l" ];
        "move-down"    = [ "<Super><Shift>j" ];
        "move-up"      = [ "<Super><Shift>k" ];
      };
      # Workspace switching + window management
      "org/gnome/desktop/wm/keybindings" = {
        "switch-to-workspace-1"  = [ "<Super>1" ];
        "switch-to-workspace-2"  = [ "<Super>2" ];
        "switch-to-workspace-3"  = [ "<Super>3" ];
        "switch-to-workspace-4"  = [ "<Super>4" ];
        "switch-to-workspace-5"  = [ "<Super>5" ];
        "switch-to-workspace-6"  = [ "<Super>6" ];
        "switch-to-workspace-7"  = [ "<Super>7" ];
        "switch-to-workspace-8"  = [ "<Super>8" ];
        "switch-to-workspace-9"  = [ "<Super>9" ];
        "switch-to-workspace-10" = [ "<Super>0" ];
        "move-to-workspace-1"    = [ "<Super><Shift>1" ];
        "move-to-workspace-2"    = [ "<Super><Shift>2" ];
        "move-to-workspace-3"    = [ "<Super><Shift>3" ];
        "move-to-workspace-4"    = [ "<Super><Shift>4" ];
        "move-to-workspace-5"    = [ "<Super><Shift>5" ];
        "move-to-workspace-6"    = [ "<Super><Shift>6" ];
        "move-to-workspace-7"    = [ "<Super><Shift>7" ];
        "move-to-workspace-8"    = [ "<Super><Shift>8" ];
        "move-to-workspace-9"    = [ "<Super><Shift>9" ];
        "move-to-workspace-10"   = [ "<Super><Shift>0" ];
        "close"             = [ "<Super><Shift>q" ];
        "toggle-fullscreen"  = [ "<Super>f" ];
      };
      # Disable default Super+number app-switching (conflicts with workspaces)
      "org/gnome/shell/keybindings" = let
        none = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
      in {
        "toggle-overview"         = [ "<Super>d" ];
        "switch-to-application-1" = none;
        "switch-to-application-2" = none;
        "switch-to-application-3" = none;
        "switch-to-application-4" = none;
        "switch-to-application-5" = none;
        "switch-to-application-6" = none;
        "switch-to-application-7" = none;
        "switch-to-application-8" = none;
        "switch-to-application-9" = none;
      };
      # Super+Return → foot terminal
      "org/gnome/settings-daemon/plugins/media-keys" = {
        "custom-keybindings" = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        "name"    = "Terminal";
        "command" = "foot";
        "binding" = "<Super>Return";
      };
    };
  }];

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

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=30day
  '';

  systemd.tmpfiles.rules = [
    "d /home/tunneller/.ssh 0700 tunneller tunneller -"
  ];

  environment.systemPackages = with pkgs; [
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
    gh

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

    # gnome extras
    gnomeExtensions.paperwm
    adwaita-icon-theme

    vscodium-fhs
    (vscode.overrideAttrs (old: rec {
      version = "1.108.0";
      src = fetchurl {
        name = "VSCode_${version}_linux-x64.tar.gz";
        url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
        sha256 = "02fzc7js802iydf1rkrxarn34f15nmqnrg8h6z0jv1y5y46rsk6v";
      };
    }))
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
      ];
    }
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}
