{config, lib, pkgs, ... }:
{
  home.username = "lucasholter";
  home.homeDirectory = "/home/lucasholter";

  home.stateVersion = "25.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
