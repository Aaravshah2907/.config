#!/usr/bin/env sh

# Isolated Yabai Space Layout Status Item
# This can be easily toggled by commenting/uncommenting its line in sketchybarrc

sketchybar --add item yabai_status left \
           --set yabai_status script="$PLUGIN_DIR/yabai_status.sh" \
                              update_freq=5 \
                              icon.font="Hack Nerd Font:Bold:16.0" \
                              label.font="JetBrainsMono Nerd Font:Bold:13.0" \
                              background.color=$BAR_COLOR \
                              background.border_color=$SAPPHIRE_TRANSLUCENT \
                              background.border_width=1 \
                              background.corner_radius=10 \
                              background.drawing=on \
                              padding_left=8 \
                              padding_right=8 \
           --subscribe yabai_status space_change window_focus
