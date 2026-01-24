{inputs, config, lib, pkgs, ...}:

let
    cfg = config.homeManagerModules.zsh;
in
{
    options.homeManagerModules.zsh.enable = lib.mkEnableOption "Enable zsh configuration";

    imports = [
        inputs.direnv-instant.homeModules.direnv-instant
    ];

    # pkgs.direnv
    # pkgs.nix-direnv
    #pkgs.zoxide

    config = lib.mkIf cfg.enable {
        home.packages = [
            pkgs.starship
        ];
        programs = {
            starship.enable = true;
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
                    # fpath+=( "${pkgs.pure-prompt}/.zsh/pure" )
                    # autoload -U promptinit; promptinit
                    # prompt pure
                '';

                shellAliases = {
                    cd = "z";
                    gs = "git status";
                    cat = "bat";
                    win = "z /mnt/c/Users/LucasCarlssonHolter/";
                    ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --grid";
                };
            };
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
        };
    };

}
