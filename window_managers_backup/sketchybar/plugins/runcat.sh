#!/usr/bin/env bash

################################################################################
# SylSpren - SketchyBar CPU Animation
#
# A lightweight, text-based CPU monitor inspired by Syl from the Cosmere.
#
# Behaviour
# ---------
# • Low CPU    → Gentle floating
# • Medium CPU → Small flight path
# • High CPU   → Fast darting
# • Max CPU    → Stormlight burst
#
# The SketchyBar interface is unchanged:
#
#   sketchybar --set "$NAME" icon="..."
#
################################################################################

# ------------------------------------------------------------------------------
# Animation Sets
# ------------------------------------------------------------------------------

IDLE_FRAMES=(
"✦"
"✧"
"⋆"
"✧"
)

FLY_FRAMES=(
"✦"
"·✦"
"··✦"
"···✦"
"··✦"
"·✦"
)

FAST_FRAMES=(
"✦·"
"·✦"
"✦••"
"••✦"
"✦⋯"
"⋯✦"
)

STORMLIGHT_FRAMES=(
"✦✧"
"✧⋆"
"⋆✦"
"✦⋆"
"⋆✧"
"✧✦"
)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

CPU_REFRESH_INTERVAL=2
LAST_CPU_UPDATE=0

CPU_USAGE=0
SLEEP_TIME=0.50

FRAME_INDEX=0

FRAMES=("${IDLE_FRAMES[@]}")

# ------------------------------------------------------------------------------
# CPU Usage
# ------------------------------------------------------------------------------

update_cpu() {

    # Total CPU usage using top
    #
    # Example output:
    # CPU usage: 12.34% user, 5.67% sys, 81.99% idle
    #

    local idle

    idle=$(top -l 1 | awk -F'[, %]+' '/CPU usage/ {print $(NF-1)}')

    if [[ -z "$idle" ]]; then
        return
    fi

    CPU_USAGE=$(awk -v idle="$idle" 'BEGIN{printf "%.0f",100-idle}')

    # Clamp

    (( CPU_USAGE < 0 )) && CPU_USAGE=0
    (( CPU_USAGE > 100 )) && CPU_USAGE=100
}

# ------------------------------------------------------------------------------
# Choose Animation
# ------------------------------------------------------------------------------

select_animation() {

    if (( CPU_USAGE < 20 )); then

        FRAMES=("${IDLE_FRAMES[@]}")

    elif (( CPU_USAGE < 45 )); then

        FRAMES=("${FLY_FRAMES[@]}")

    elif (( CPU_USAGE < 75 )); then

        FRAMES=("${FAST_FRAMES[@]}")

    else

        FRAMES=("${STORMLIGHT_FRAMES[@]}")

    fi

    FRAME_COUNT=${#FRAMES[@]}
    FRAME_INDEX=$(( FRAME_INDEX % FRAME_COUNT ))
}

# ------------------------------------------------------------------------------
# Animation Speed
# ------------------------------------------------------------------------------

update_speed() {

    if (( CPU_USAGE < 20 )); then

        SLEEP_TIME=0.50

    elif (( CPU_USAGE < 40 )); then

        SLEEP_TIME=0.35

    elif (( CPU_USAGE < 60 )); then

        SLEEP_TIME=0.22

    elif (( CPU_USAGE < 80 )); then

        SLEEP_TIME=0.12

    else

        SLEEP_TIME=0.06

    fi
}

# ------------------------------------------------------------------------------
# Main Loop
# ------------------------------------------------------------------------------

while true; do

    now=$(date +%s)

    if (( now - LAST_CPU_UPDATE >= CPU_REFRESH_INTERVAL )); then

        update_cpu
        select_animation
        update_speed

        LAST_CPU_UPDATE=$now

    fi

    sketchybar --set "$NAME" icon="${FRAMES[$FRAME_INDEX]}"

    FRAME_INDEX=$(( (FRAME_INDEX + 1) % FRAME_COUNT ))

    sleep "$SLEEP_TIME"

done
