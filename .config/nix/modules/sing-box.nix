{
  config,
  lib,
  pkgs,
  ...
}: {
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
            tag = "doh-dns";
            type = "https";
            server = "8.8.8.8";
            detour = "vless-out";
          }
          {
            tag = "doh-direct";
            type = "https";
            server = "77.88.8.8";
          }
        ];
        rules = [
          {
            rule_set = ["refilter_domains"];
            server = "doh-dns";
          }
        ];
        final = "doh-direct";
      };
      inbounds = [
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "tun0";
          mtu = 9000;
          address = ["172.19.0.1/30"];
          stack = "system";
          auto_route = true;
          strict_route = true;
          auto_redirect = true;
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
            server_name._secret = config.sops.secrets.singbox_hy2_sni.path;
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
        }
      ];
      route = {
        default_domain_resolver = {
          server = "doh-direct";
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
            ip_cidr = ["208.76.170.0/24"];
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
        ];
        rule_set = [
          {
            tag = "refilter_domains";
            type = "remote";
            format = "binary";
            url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-domain-refilter_domains.srs";
            download_detour = "direct-out";
          }
          {
            tag = "refilter_ipsum";
            type = "remote";
            format = "binary";
            url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-ip-refilter_ipsum.srs";
            download_detour = "direct-out";
          }
          {
            tag = "custom";
            type = "inline";
            rules = [
              {
                domain = [
                  "kino.pub"
                  "rezka.ag"
                  "rutracker.org"
                  "nixos.wiki"
                  "wiki.nixos.org"
                  "search.nixos.org"
                  "cache.nixos.org"
                  "cdn2cdn.com"
                  "qdrant.tech"
                  "happ.su"
                  "towardsdatascience.com"
                  "slsknet.org"
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
