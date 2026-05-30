HISTFILE="$XDG_CACHE_HOME/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
mkdir -p "$XDG_CACHE_HOME/zsh"

setopt appendhistory
setopt incappendhistory
setopt sharehistory
setopt histignorealldups
setopt extended_history

source <(fzf --zsh)

alias dtf='git --git-dir=$HOME/.config/dots.git --work-tree=$HOME'

setopt autocd

# Basic auto/tab complete:
zmodload zsh/complist
autoload -U compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
autoload -U colors && colors
zstyle ':completion:*' menu select
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
_comp_options+=(globdots)

# fzf-tab (must load after compinit)
source "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

# vi mode
bindkey -v

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[6 q"
}
zle -N zle-line-init
echo -ne '\e[6 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[6 q' ;} # Use beam shape cursor for each new prompt.

# System clipboard integration
source "$XDG_DATA_HOME/zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
