{...}: {
  sops.secrets.singbox_uuid = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_public_key = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_short_id = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_server = {sopsFile = ../secrets/common.yaml; mode = "0444";};
  sops.secrets.singbox_port = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_sni = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_hy2_password = {sopsFile = ../secrets/common.yaml;};
  sops.secrets.singbox_hy2_sni = {sopsFile = ../secrets/common.yaml;};
}
