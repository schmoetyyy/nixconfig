{ config, pkgs, ... }:

{
  home = {
    username = "schmoetyyy";
    homeDirectory = "/home/schmoetyyy";
    stateVersion = "26.05";

    file.".config/kitty/kitty.conf".source = ./qhd-dots/kitty/kitty.conf;

    file.".config/hypr/hyprland.lua".source = ./qhd-dots/hypr/hyprland.lua;
    file.".config/hypr/hyprpaper.conf".source = ./qhd-dots/hypr/hyprpaper.conf;

    file.".config/waybar/config.jsonc".source = ./qhd-dots/waybar/config.jsonc;
    file.".config/waybar/style.css".source = ./qhd-dots/waybar/style.css;
    file.".config/waybar/scipts/network.sh".source = ./qhd-dots/waybar/scripts/network.sh;
    file.".config/waybar/scipts/toggle-nmapplet.sh".source = ./qhd-dots/waybar/scripts/toggle-nmapplet.sh;
   
    file.".config/fastfetch/config.jsonc".source = ./qhd-dots/fastfetch/config.jsonc;

    file.".config/rofi/config.rasi".source = ./qhd-dots/rofi/config.rasi;
    file.".config/rofi/powermenu.sh".source = ./qhd-dots/rofi/powermenu.sh;
    file.".config/rofi/shutdown.sh".source = ./qhd-dots/rofi/shutdown.sh;

    file.".config/yazi/yazi.toml" .source = ./qhd-dots/yazi/yazi.toml;
    file.".config/yazi/init.lua" .source = ./qhd-dots/yazi/init.lua;
    file.".config/yazi/theme.toml" .source = ./qhd-dots/yazi/theme.toml;
    file.".config/yazi/package.toml" .source = ./qhd-dots/yazi/package.toml;
    file.".config/yazi/keymap.toml" .source = ./qhd-dots/yazi/keymap.toml;
    file.".config/yazi/plugins/folder-rules.yazi/main.lua" .source = ./qhd-dots/yazi/plugins/folder-rules.yazi/main.lua;
    file.".config/yazi/flavors/gruvbox-light.yazi" .source = ./qhd-dots/yazi/flavors/gruvbox-light.yazi;
    file.".config/swaync/config.json".source = ./qhd-dots/swaync/config.json;
    file.".config/swaync/style.css".source = ./qhd-dots/swaync/style.css;

    file.".local/share/PrismLauncher/themes/gruvboxTheme/theme.json".source = ./qhd-dots/PrismLauncher/themes/gruvboxTheme/theme.json;
    file.".local/share/PrismLauncher/themes/gruvboxTheme/themeStyle.css".source = ./qhd-dots/PrismLauncher/themes/gruvboxTheme/themeStyle.css;

    file.".vimrc".source = ./qhd-dots/.vimrc;
    file.".bashrc".source = ./qhd-dots/.bashrc;
  };
}
