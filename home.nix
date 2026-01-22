{ config, lib, pkgs, ... }:

let
  zsh-syntax-highlighting = pkgs.fetchFromGitHub {
  owner = "zsh-users";
  repo = "zsh-syntax-highlighting";
  rev = "5eb677b";
  sha256 = "sha256-KRsQEDRsJdF7LGOMTZuqfbW6xdV5S38wlgdcCM98Y/Q=";
};
  nvimConfig = pkgs.fetchFromGitHub {
  owner = "lucasholter00";
  repo = "barebones-nvim";
  rev = "2d29ecc";
  sha256 = "sha256-SVToLRkIndTqh84Mk7ZhBnG0vwM7kAnF2Pi2bxZyHyg=";
};
  dotfiles = pkgs.fetchFromGitHub {
  owner = "lucasholter00";
  repo = "dotfiles";
  rev = "9f59e63";
  sha256 = "sha256-rjzA86ncRCRH9BKoZVY1n5BA75UdSUP5BKLcukyF/OQ=";
};
in 
{
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
    pkgs.tmux
    pkgs.zsh
    pkgs.neovim
    pkgs.eza
    pkgs.zoxide
    pkgs.curl
    pkgs.bash
    pkgs.nodejs_24
    pkgs.cargo
    pkgs.gccgo15
    pkgs.zsh-autosuggestions
    pkgs.tree
    pkgs.direnv
    pkgs.nix-direnv

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file.".config/nvim" = {
    source = "${nvimConfig}/";
    target = ".config/nvim/";
  };

  home.file.".oh-my-zsh/custom/plugins/zsh-autosuggestions" = {
    source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
    target = ".oh-my-zsh/custom/plugins/zsh-autosuggestions" ;
  };

  home.file.".oh-my-zsh/custom/plugins/zsh-syntax-highlighting" = {
    source = "${zsh-syntax-highlighting}";
    target = ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ;
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

    ".zshrc".source = "${dotfiles}/.zshrc";
    ".tmux.conf".source = "${dotfiles}/.tmux.conf";
    ".p10k.zsh".source = "${dotfiles}/.p10k.zsh";
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
    # EDITOR = "emacs";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
