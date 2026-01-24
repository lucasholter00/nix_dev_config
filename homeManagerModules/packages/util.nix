{pkgs, config, lib, ...}:
let
    cfg = config.homeManagerModules.util;
in
{
    options.homeManagerModules.util.enable = lib.mkEnableOption "Enable util configuration";
    config = lib.mkIf cfg.enable {
        home.packages = [

            pkgs.bat
            pkgs.neovim
            pkgs.eza
            pkgs.curl
            pkgs.bash
            pkgs.nodejs_24
            pkgs.cargo
            pkgs.gccgo15
            pkgs.tree
            pkgs.gnumake
            pkgs.tldr

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
    };
}
