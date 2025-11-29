```bash
git clone --bare git@github.com/fvrrrn/dotfiles.git ~/.dtf
alias dtf='git --git-dir=$HOME/.dtf/ --work-tree=$HOME/'
dtf checkout
dtf config --local status.showUntrackedFiles no
```

To install neovim dependencies such as TreeSitter or native-fzf run:
```sh
nix shell nixpkgs#gcc nixpkgs#gnumake
```

provider: `gpg2 --export-secret-keys > pass.gpg`

consumer: `scp pc:~/pass.gpg pass.gpg && gpg2 --import pass.gpg && rm pass.gpg`

consumer: `git clone ssh://pc/~/.password-store/.git ~/.password-store`

If Chrome cannot be launched try `rm -rf ~/.config/chromium/Single*`
