{direnv-instant ,config, lib, pkgs, ... }:

let
  nvimConfig = pkgs.fetchFromGitHub {
  owner = "lucasholter00";
  repo = "barebones-nvim";
  rev = "f54e624";
  sha256 = "sha256-z6DjbZz92WqQGQTaWvVwylHWXza4KVEaA91Cna65yCg=";
};
in 
{
  imports = [
    direnv-instant.homeModules.direnv-instant
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lucasholter";
  home.homeDirectory = "/home/lucasholter";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?

    pkgs.git
    pkgs.bat
    pkgs.tmux
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.neovim
    pkgs.eza
    pkgs.zoxide
    pkgs.curl
    pkgs.bash
    pkgs.nodejs_24
    pkgs.cargo
    pkgs.gccgo15
    pkgs.tree
    pkgs.direnv
    pkgs.nix-direnv
    pkgs.meslo-lgs-nf
    pkgs.oh-my-posh
    pkgs.gnumake
    pkgs.tldr

    #tmux line dependencies
    pkgs.jq
    pkgs.notonoto
    pkgs.bc

    #nvim dependencies
    pkgs.ripgrep
    pkgs.fzf

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (pkgs.writeShellScriptBin "flakify" ''
      if [ ! -e flake.nix ]; then
        nix flake new -t github:nix-community/nix-direnv .
      elif [ ! -e .envrc ]; then
        echo "use flake" > .envrc
        direnv allow
      fi
      ''${EDITOR:-vim} flake.nix
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file.".config/nvim" = {
    source = "${nvimConfig}/";
    target = ".config/nvim/";
  };

  home.file.".fonts" = {
    source = "${pkgs.meslo-lgs-nf}";
    target = ".fonts";
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

  };

  home.activation = {
    installOmz = lib.hm.dag.entryAfter ["writeBoundary" "installPackages" "zsh"] ''
      export PATH="${
        lib.makeBinPath (with pkgs; [zsh git])
      }:$PATH"
      if [ -d "''${HOME}/.oh-my-zsh" ]; then
        echo "Oh my zsh already installed"
      else
        run sh -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh ) --unattended"
      fi
      if [ -d "''${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo "Powerlevel10k already installed"
      else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "''${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
      fi
    '';
  };     

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lucasholter/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs = {

    direnv = {
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
      silent = true;
    };
    direnv-instant.enable = true;
    zoxide = {
        enable = true;
        enableZshIntegration = true;
    };

    zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        oh-my-zsh = {
            enable = true;
            plugins = [
                "git"
                "web-search"
            ];
        };

        initContent = ''
            eval $(ssh-agent) &> /dev/null
            ssh-add ~/.ssh/github &> /dev/null
        '';

        shellAliases = {
            cd = "z";
            gs = "git status";
            cat = "bat";
            win = "z /mnt/c/Users/LucasCarlssonHolter/";
            ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --grid";
        };
    };
    oh-my-posh = {
        enable = true;
        settings = builtins.fromJSON (builtins.readFile ./oh-my-posh-themes/tokyonight_storm_nix.json);
    };

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
            # {
            #     plugin = tmuxPlugins.dracula;
            #     extraConfig = ''
            #       set -g @dracula-show-powerline true
            #       set -g @dracula-show-left-icon session
            #       set -g @dracula-show-flags true
            #       set -g @dracula-border-contrast true
            #       set -g @dracula-plugins "battery time"
            #       set -g @dracula-day-month true
            #       set -g @dracula-show-timezone false
            #       # default is 1, it can accept any number and 0 disables padding.
            #       set -g @dracula-left-icon-padding 1
            #       set -g @dracula-military-time true
            #       set -g status-position top
            #     '';
            # }
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

    git = {
        enable = true;
        settings = {
            user = {
                name = "Lucas Holter";
                email = "lucas.holter@hotmail.com";
            };
        };
    };

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
