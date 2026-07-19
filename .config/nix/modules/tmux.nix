{...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    historyLimit = 50000;
    escapeTime = 0;
    terminal = "tmux-256color";
    extraConfig = ''
      # Copy mode vim bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # True color support
      set -ag terminal-overrides ",*:RGB"

      # Mouse support (scrolling)
      set -g mouse on

      # Start windows and panes at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Auto-attach or create session on new terminal
      new-session -A -s main
    '';
  };
}
