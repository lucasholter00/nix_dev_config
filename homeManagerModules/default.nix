{config, pkgs, lib, ...}:
{
    imports = [
        ./programs/git.nix
        ./programs/zsh.nix
        ./programs/tmux.nix
        ./packages/nvim.nix
        ./packages/util.nix
        ./sessionVariables/vars.nix
    ];

    homeManagerModules.git.enable = lib.mkDefault true;
    homeManagerModules.zsh.enable = lib.mkDefault true;
    homeManagerModules.tmux.enable = lib.mkDefault true;
    homeManagerModules.nvim.enable = lib.mkDefault true;
    homeManagerModules.util.enable = lib.mkDefault true;
    homeManagerModules.vars.enable = lib.mkDefault true;
}
