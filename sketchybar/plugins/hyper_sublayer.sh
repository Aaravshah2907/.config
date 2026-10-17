#!/bin/bash

source "$HOME/.local/bin/cosmere_colors.sh"

case "$SUBLAYER" in
  "O")
    sketchybar --set hyper_sublayer \
               drawing=on \
               icon="󰀻" \
               icon.color="$SAPPHIRE" \
               icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
               label="APPS" \
               label.color="$WHITE" \
               label.font="JetBrainsMono Nerd Font:Bold:11.0" \
               background.color="$DEEP_NIGHT" \
               background.border_color="$SAPPHIRE" \
               background.border_width=1 \
               background.corner_radius=8 \
               background.drawing=on \
               padding_left=4 \
               padding_right=6
    ;;
  "B")
    sketchybar --set hyper_sublayer \
               drawing=on \
               icon="󰖟" \
               icon.color="$EMERALD" \
               icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
               label="BROWSE" \
               label.color="$WHITE" \
               label.font="JetBrainsMono Nerd Font:Bold:11.0" \
               background.color="$DEEP_NIGHT" \
               background.border_color="$EMERALD" \
               background.border_width=1 \
               background.corner_radius=8 \
               background.drawing=on \
               padding_left=4 \
               padding_right=6
    ;;
  "S")
    sketchybar --set hyper_sublayer \
               drawing=on \
               icon="󰒓" \
               icon.color="$HONOR_GOLD" \
               icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
               label="SYSTEM" \
               label.color="$WHITE" \
               label.font="JetBrainsMono Nerd Font:Bold:11.0" \
               background.color="$DEEP_NIGHT" \
               background.border_color="$HONOR_GOLD" \
               background.border_width=1 \
               background.corner_radius=8 \
               background.drawing=on \
               padding_left=4 \
               padding_right=6
    ;;
  "T")
    sketchybar --set hyper_sublayer \
               drawing=on \
               icon="󰓩" \
               icon.color="$AMBER" \
               icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
               label="TABS" \
               label.color="$WHITE" \
               label.font="JetBrainsMono Nerd Font:Bold:11.0" \
               background.color="$DEEP_NIGHT" \
               background.border_color="$AMBER" \
               background.border_width=1 \
               background.corner_radius=8 \
               background.drawing=on \
               padding_left=4 \
               padding_right=6
    ;;
  "C")
    sketchybar --set hyper_sublayer \
               drawing=on \
               icon="󱓞" \
               icon.color="$VIOLET" \
               icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
               label="TOOLS" \
               label.color="$WHITE" \
               label.font="JetBrainsMono Nerd Font:Bold:11.0" \
               background.color="$DEEP_NIGHT" \
               background.border_color="$VIOLET" \
               background.border_width=1 \
               background.corner_radius=8 \
               background.drawing=on \
               padding_left=4 \
               padding_right=6
    ;;
  *)
    sketchybar --set hyper_sublayer drawing=off
    ;;
esac
