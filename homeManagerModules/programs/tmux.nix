{config, lib, pkgs, ...}:
let
    cfg = config.homeManagerModules.tmux;
in
{
    options.homeManagerModules.tmux.enable = lib.mkEnableOption "Enable tmux configuration";

    config = lib.mkIf cfg.enable {
        home.packages = [
            #tmux line dependencies
            pkgs.jq
            pkgs.notonoto
            pkgs.bc
        ];
        programs = {
            tmux = {
                enable = true;
                prefix = "C-a";
                keyMode = "vi";
                shell = "${pkgs.zsh}/bin/zsh";
                terminal = "xterm-256color";
                clock24 = true;
                extraConfig = ''
                  set-option -ga terminal-overrides ",xterm-256color:Tc"
                  set -g status-position top
                  set -g status-justify left
                  unbind ";"
                  bind ";" split-window -h
                  unbind '"'
                  bind '-' split-window -v
                  unbind r
                  bind r source-file ~/.config/tmux/tmux.conf
                  bind -r j resize-pane -D 5
                  bind -r k resize-pane -U 5
                  bind -r l resize-pane -R 5
                  bind -r h resize-pane -L 5
                  bind -r m resize-pane -Z
                  bind-key -T copy-mode-vi 'v' send -X begin-selection
                  bind-key -T copy-mode-vi 'y' send -X copy-selection
                '';
                plugins = with pkgs; [
                    {
                        plugin = tmuxPlugins.tokyo-night-tmux;
                        extraConfig = ''
                            set -g @tokyo-night-tmux_theme storm    # storm | day | default to 'night'
                            set -g @tokyo-night-tmux_transparent 1  # 1 or 0
                            set -g @tokyo-night-tmux_terminal_icon 
                            set -g @tokyo-night-tmux_active_terminal_icon 
                            set -g @tokyo-night-tmux_show_datetime 0
                            set -g @tokyo-night-tmux_date_format DMY
                            set -g @tokyo-night-tmux_time_format 24H
                            set -g @tokyo-night-tmux_window_id_style fsquare
                            set -g @tokyo-night-tmux_pane_id_style hsquare
                            set -g @tokyo-night-tmux_zoom_id_style dsquare
                            # No extra spaces between icons
                            set -g @tokyo-night-tmux_window_tidy_icons 0
                        '';
                    }
                    {
                        plugin = tmuxPlugins.vim-tmux-navigator;
                    }
                    {
                        plugin = tmuxPlugins.resurrect;
                        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
                    }
                    {
                        plugin = tmuxPlugins.continuum;
                        extraConfig = "set -g @continuum-restore 'on'";
                    }
                ];
            };
        };
    };

}
