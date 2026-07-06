# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Apply config to current host (pc or t480)
sudo nixos-rebuild switch --flake .#pc
sudo nixos-rebuild switch --flake .#t480

# Test a build without setting it as the default boot entry
sudo nixos-rebuild test --flake .#pc

# Format all nix files
alejandra .

# Update all flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs

# Check the flake for errors
nix flake check

# Search available packages
nix search nixpkgs <name>
```

## Architecture

**Entry point:** `flake.nix` defines two `nixosConfigurations` (`pc` and `t480`). It passes `inputs` and `hostname` as `specialArgs` to every module.

**Shared base:** `configuration.nix` receives `{ pkgs, hostname, inputs, ... }` and configures everything common to both hosts — users, locale, Sway/Wayland, audio (pipewire), networking (NetworkManager; DNS is handled by sing-box's hijack-dns, see Sing-box section), fonts, and the main package list.

**Per-host modules** in `modules/` are selectively added to each host in `flake.nix`:
- `network.nix` — Hostname, NetworkManager, firewall, Amnezia VPN, DNS utilities (both hosts)
- `nvidia.nix` — Nvidia open kernel module + modesetting (pc only)
- `sing-box.nix` — TUN-based proxy with VLESS/XTLS-Reality outbound and routing rule sets
- `autossh.nix` — Reverse SSH tunnel service via `tunneller` user to `vps_tunnel`
- `syncthing.nix` — Syncthing for user `fvrn`
- `llama.nix` — llama.cpp with CUDA support + llama-swap (pc only)
- `steam.nix` — Steam (t480 only)
- `sshd.nix` — SSH daemon (pc only)

**Hardware configs** live in `hardware/<hostname>/hardware-configuration.nix` (auto-generated, not hand-edited).

**External flake inputs** (`zen-browser`, `eden-flake`) are consumed in `configuration.nix` via the `inputs` specialArg to pull packages not in nixpkgs.

**Nix formatter:** `alejandra`. **Nix LSP:** `nil`.

## Sing-box (`modules/sing-box.nix`)

Split-tunnel proxy for bypassing Russian censorship. TUN-based (`auto_route + strict_route`) with a VLESS/XTLS-Reality outbound to a VPS (server/uuid/keys in sops).

**Routing intent:**
- Default (`route.final = "direct-out"`): traffic goes direct, no proxy round-trip.
- Domains/IPs in `refilter_*` rule sets → `vless-out` (through VPS).
- Private IPs (`ip_is_private`) → `direct-out`.

**Refilter rule sets** (`refilter_domains`, `refilter_ipsum`) come from [1andrevich/Re-filter-lists](https://github.com/1andrevich/Re-filter-lists). These are sites **BLOCKED BY** Russia (sites needing the proxy to be reachable), NOT sites *hosted in* Russia. They must route to `vless-out`. The naming is easy to misread — do not flip this.

**DNS:**
- `local-dns` (`type = "local"`) — kept only as `domain_resolver` on outbounds (VPS hostname bootstrap). **Do not use as `dns.final` or `default_domain_resolver`** — it causes an infinite loop: `type = "local"` uses Go's system resolver → 127.0.0.53 → systemd-resolved → tun0 (172.19.0.2, sing-box's fake DNS) → sing-box applies DNS rules → `local-dns` again. The loop produces `use of closed network connection` / `context deadline exceeded` for all cold-cache domains. The cache_file masks this when warm, making it appear to work until entries expire or the cache is cleared (e.g. after a rebuild).
- `doh-dns` (`type = "https"`, `server = "8.8.8.8"`, no detour) — DoH directly to Google DNS. Sing-box's own process traffic bypasses the TUN via routing mark, so this reaches 8.8.8.8 without looping. Used for all DNS (`dns.final = "doh-dns"`).
- `dns.final = "doh-dns"` — all DNS goes through DoH. Do not change this to `local-dns`.

**Critical conflict with Amnezia VPN:** `configuration.nix` has `programs.amnezia-vpn.enable = true` (just installs the package). If Amnezia is actively connected (`amn0` interface present, `0.0.0.0/1 dev amn0` in routes), sing-box's TUN routing fights with it and connections to the VPS fail with `i/o timeout` / `no route to internet`. Disconnect Amnezia before starting sing-box. Quick check: `ip link show amn0`.

**Sing-box's own VPS dial bypasses its own TUN** via an auto-added route exception — `ip route get <vps-ip>` should show `via 192.168.1.1 dev wlp3s0`, NOT via `tun0`. Required to avoid loops.

**Verifying it works:**
```bash
systemctl is-active sing-box
ss -tn state established '( dst <vps-ip> )'    # should show active VLESS sessions
curl -sI --max-time 10 https://rutracker.org   # blocked site loads → proxy working
```

Startup may briefly emit `missing default interface` / `no route to internet` errors while the network settles — self-corrects within seconds, safe to ignore.

## Adding a New Module

1. Create `modules/<name>.nix` with signature `{ pkgs, ... }:` or `{ config, pkgs, ... }:`.
2. Add the module path to the relevant host's `modules` list in `flake.nix`.
3. Run `alejandra modules/<name>.nix` to format before committing.
