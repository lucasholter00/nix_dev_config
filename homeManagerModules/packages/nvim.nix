{inputs, config, lib, pkgs, ...}:
let
    cfg = config.homeManagerModules.nvim;
in
{
    options.homeManagerModules.nvim.enable = lib.mkEnableOption "Enable nvim configuration";

    config = lib.mkIf cfg.enable {
        home.packages = [
            #nvim dependencies
            pkgs.ripgrep
            pkgs.fzf
            pkgs.tree-sitter
            pkgs.rust-analyzer
        ];

    };
}
