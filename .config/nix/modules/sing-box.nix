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
            server = "8.8.8.8";
            detour = "vless-out";
          }
        ];
        rules = [
          {
            rule_set = ["refilter_domains"];
            server = "doh-dns";
          }
        ];
        final = "local-dns";
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
            outbound = "vless-out";
          }
          {
            rule_set = "custom";
            outbound = "vless-out";
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
                  "cdn2cdn.com"
                  "qdrant.tech"
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
