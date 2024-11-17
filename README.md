```bash
git clone --bare git@github.com/fvrrrn/dotfiles-public.git ~/.dtf
alias dtf='git --git-dir=$HOME/.dtf/ --work-tree=$HOME/'
rm ~/.config/fish/fish_variables && rm ~/.config/fish/config.fish
dtf checkout
dtf config --local status.showUntrackedFiles no
```
