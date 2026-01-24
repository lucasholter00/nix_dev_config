{config, lib, pkgs, ...}:

let
    cfg = config.homeManagerModules.git;
in
{
    options.homeManagerModules.git.enable = lib.mkEnableOption "Enable git configuration";

    config = lib.mkIf cfg.enable {
        programs = {
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
    };

}
