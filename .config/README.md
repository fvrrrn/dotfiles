# dotfiles

## Structure

```
~/.config/
├── dots.git/        # bare git repo (git dir) — tracks all dotfiles
├── nix/             # NixOS configuration (own git repo → github.com/fvrrrn/nixcfg)
│   ├── flake.nix
│   ├── configuration.nix
│   ├── modules/
│   ├── hardware/
│   └── secrets/     # SOPS-encrypted
├── zsh/
│   ├── .zshrc
│   └── .zprofile
├── emacs/init.el
├── foot/foot.ini
├── nvim/
├── sway/
└── tmux/tmux.conf

~/.zshenv            # sets XDG vars and ZDOTDIR=$HOME/.config/zsh
~/.gitconfig
~/.gitconfig-s21

~/.local/share/zsh/plugins/    # zsh plugins (plain clones, not tracked)
├── fzf-tab/
└── zsh-system-clipboard/
```

## Bootstrap (new machine)

```sh
git clone --bare git@github.com:fvrrrn/dotfiles.git ~/.config/dots.git
alias dtf='git --git-dir=$HOME/.config/dots.git --work-tree=$HOME'
dtf checkout
dtf config --local status.showUntrackedFiles no

# clone zsh plugins
mkdir -p ~/.local/share/zsh/plugins
git clone https://github.com/kutsan/zsh-system-clipboard ~/.local/share/zsh/plugins/zsh-system-clipboard
git clone https://github.com/Aloxaf/fzf-tab ~/.local/share/zsh/plugins/fzf-tab
```

## NixOS

```sh
cd ~/.config/nix
make switch    # apply config to current host (auto-detects pc/t480)
make update    # update flake inputs
make upgrade   # update + switch
```

## Neovim dependencies

```sh
nix shell nixpkgs#gcc nixpkgs#gnumake
```

## GPG / password-store

Export: `gpg2 --export-secret-keys > pass.gpg`

Import: `scp pc:~/pass.gpg pass.gpg && gpg2 --import pass.gpg && rm pass.gpg`

Clone store: `git clone ssh://pc/~/.password-store/.git ~/.password-store`

### Pass for iOS (same-network sync via SSH)

Git URL: `fvrn@192.168.1.11:~/.password-store`

The repo is configured to accept pushes to the checked-out branch:
```sh
git -C ~/.password-store config receive.denyCurrentBranch updateInstead
```

SSH key for iOS is at `~/.ssh/pass-ios` (public key already in `~/.ssh/authorized_keys`).

GPG subkey export for import into Pass for iOS:
```sh
gpg --export -a DC03683AFD35818A031B93B715166DFFB61E9F60! > ~/subkey-pub.gpg
gpg --export-secret-subkeys -a DC03683AFD35818A031B93B715166DFFB61E9F60! > ~/subkey.gpg
```

## SOPS secrets (inside ~/.config/nix/)

Encrypt:
```sh
sudo SOPS_AGE_KEY=$(sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key) \
  nix run nixpkgs#sops -- --encrypt --in-place secrets/common.yaml
```

Edit:
```sh
sudo SOPS_AGE_KEY=$(sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key) \
  nix run nixpkgs#sops -- secrets/common.yaml
```

## Misc

Chromium won't launch: `rm -rf ~/.config/chromium/Single*`
