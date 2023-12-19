# Disable welcome message when creating new shell
set fish_greeting ''


alias git-dtf='/usr/bin/git --git-dir=$HOME/.git-dtf/ --work-tree=$HOME' 

if status is-interactive
    # Commands to run in interactive sessions can go here
end
