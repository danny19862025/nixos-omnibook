{ config, pkgs, ... }:
{
  home.username = "danny";
  home.homeDirectory = "/home/danny";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
