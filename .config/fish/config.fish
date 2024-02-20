# Disable welcome message when creating new shell
set fish_greeting ''

fish_vi_key_bindings

alias dtf='/usr/bin/git --git-dir=$HOME/.dtf/ --work-tree=$HOME' 

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block


set tide_character_icon \x3e
set tide_character_vi_icon_default \x3e
set tide_character_vi_icon_replace \x3e
set tide_character_vi_icon_visual \x3e


set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH $HOME/.ghcup/bin # ghcup-env

