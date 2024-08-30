# Disable welcome message when creating new shell
set fish_greeting ''

fish_vi_key_bindings

alias dtf='git --git-dir=$HOME/.dtf/ --work-tree=$HOME' 

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
