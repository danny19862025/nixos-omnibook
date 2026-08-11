{ config, pkgs, ... }:
{
  home.username = "danny";
  home.homeDirectory = "/home/danny";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tela-icon-theme
    whitesur-gtk-theme
    gnomeExtensions.dash-to-dock
     gnomeExtensions.appindicator
    gnome-tweaks
  ];

  dconf.settings = {
  "org/gnome/desktop/interface" = {
    icon-theme = "Tela-circle-orange";
    gtk-theme = "WhiteSur-Dark";
  };


  "org/gnome/desktop/wm/preferences" = {
    button-layout = "close,minimize,maximize:";
  };
  "org/gnome/shell" = {
    enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "appindicatorsupport@rgcjonas.gmail.com" ];
  };
  "org/gnome/shell/extensions/dash-to-dock" = {
    dock-position = "BOTTOM";
    transparency-mode = "DYNAMIC";
    dash-max-icon-size = 48;
    extend-height = false;
  };
};
}
