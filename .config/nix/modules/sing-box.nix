{
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets.singbox_uuid = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_public_key = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_short_id = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_server = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_port = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_sni = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_hy2_password = {sopsFile = ../secrets/common.yaml;};

  services.sing-box = {
    enable = true;
    package = pkgs.sing-box;
    settings = {
      log = {
        level = "warn";
        timestamp = true;
      };
      dns = {
        servers = [
          {
            tag = "local-dns";
            type = "local";
          }
          {
            tag = "doh-dns";
            type = "https";
            server = "1.1.1.1";
          }
        ];
        rules = [
          {
            rule_set = ["refilter_domains"];
            server = "doh-dns";
          }
        ];
        final = "doh-dns";
        strategy = "prefer_ipv4";
      };
      inbounds = [
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "tun0";
          mtu = 9000;
          address = [
            "172.19.0.1/30"
            "fdfe:dcba:9876::1/126"
          ];
          stack = "system";
          auto_route = true;
          strict_route = true;
          auto_redirect = true;
          exclude_interface = ["enp0s31f6"];
        }
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct-out";
        }
        {
          type = "hysteria2";
          tag = "hy2";
          server._secret = config.sops.secrets.singbox_server.path;
          server_port = 443;
          password._secret = config.sops.secrets.singbox_hy2_password.path;
          tls = {
            enabled = true;
            server_name._secret = config.sops.secrets.singbox_server.path;
          };
        }
        {
          type = "urltest";
          tag = "hy2-out";
          outbounds = ["hy2" "vless-out"];
          url = "https://www.gstatic.com/generate_204";
          interval = "3m";
          tolerance = 50;
          idle_timeout = "30m";
        }
        {
          type = "vless";
          tag = "vless-out";
          server._secret = config.sops.secrets.singbox_server.path;
          server_port = 0;
          uuid._secret = config.sops.secrets.singbox_uuid.path;
          flow = "xtls-rprx-vision";
          tls = {
            enabled = true;
            server_name._secret = config.sops.secrets.singbox_sni.path;
            utls = {
              enabled = true;
              fingerprint = "randomized";
            };
            reality = {
              enabled = true;
              public_key._secret = config.sops.secrets.singbox_public_key.path;
              short_id._secret = config.sops.secrets.singbox_short_id.path;
            };
          };
          domain_resolver = {
            server = "local-dns";
            rewrite_ttl = 60;
            client_subnet = "1.1.1.1";
          };
        }
      ];
      route = {
        default_domain_resolver = {
          server = "local-dns";
          rewrite_ttl = 60;
        };
        rules = [
          {
            inbound = ["tun-in"];
            action = "sniff";
          }
          {
            rule_set = [
              "refilter_domains"
              "refilter_ipsum"
            ];
            outbound = "hy2-out";
          }
          {
            rule_set = "custom";
            outbound = "hy2-out";
          }
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          {
            ip_is_private = true;
            outbound = "direct-out";
          }
          {
            ip_version = 6;
            outbound = "hy2-out";
          }
        ];
        rule_set = [
          {
            tag = "refilter_domains";
            type = "remote";
            format = "binary";
            url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-domain-refilter_domains.srs";
            download_detour = "hy2-out";
          }
          {
            tag = "refilter_ipsum";
            type = "remote";
            format = "binary";
            url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-ip-refilter_ipsum.srs";
            download_detour = "hy2-out";
          }
          {
            tag = "custom";
            type = "inline";
            rules = [
              {
                domain = [
                  "ntc.party"
                  "kino.pub"
                  "rezka.ag"
                  "rutracker.org"
                  "nixos.wiki"
                  "wiki.nixos.org"
                  "search.nixos.org"
                  "cdn2cdn.com"
                  "qdrant.tech"
                  "happ.su"
                ];
              }
            ];
          }
        ];
        final = "direct-out";
        auto_detect_interface = true;
      };
      experimental = {
        cache_file = {
          enabled = true;
        };
      };
    };
  };

  systemd.services.sing-box.serviceConfig.ExecStartPre = lib.mkAfter [
    (pkgs.writeShellScript "singbox-patch-port" ''
      port=$(cat ${config.sops.secrets.singbox_port.path})
      [[ -n "$port" ]] || { echo "singbox_port secret is empty"; exit 1; }
      ${pkgs.gnused}/bin/sed -i "s/\"server_port\": 0/\"server_port\": $port/" /run/sing-box/config.json
    '')
  ];
}
