{lib, pkgs, config, ...}:
let
    cfg = config.homeManagerModules.vars;
in
{
    options.homeManagerModules.vars.enable = lib.mkEnableOption "Enable Session Variable configuration";

    config = lib.mkIf cfg.enable {
        home.sessionVariables = {
          EDITOR = "nvim";
          SHELL = "${pkgs.zsh}/bin/zsh";
        };
    };
}
