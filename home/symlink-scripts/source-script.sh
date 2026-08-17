#!/usr/bin/env bash
set -euo pipefail

CONFIG_SRC=~/nixconfig/home/qhd-dots
CONFIG_DST=~

# source (from ~nixconfig):destination (from home folder)
items=(
  "fastfetch:.config/fastfetch"
  "hypr:.config/hypr"
  "kitty:.config/kitty"
  "PrismLauncher/themes:.local/share/PrismLauncher/themes"
  "rofi:.config/rofi"
  "swaync:.config/swaync"
  "waybar:.config/waybar"
  "yazi:.config/yazi"
  "zed:.config/zed" 
  ".bashrc:.bashrc"
  ".vimrc:.vimrc"
)

for item in "${items[@]}"; do
  src_name="${item%%:*}"
  dst_name="${item##*:}"

  source="$CONFIG_SRC/$src_name"
  target="$CONFIG_DST/$dst_name"

  if [ ! -e "$source" ]; then
    echo "⚠️  Source missing, scipping: $source"
    continue
  fi

  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -d "$target" ] || [ -f "$target" ]; then
    backup="${target}.bak.$(date +%s)"
    echo "Saving existing $target to $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "✓ $target -> $source"
done

echo "Done."
