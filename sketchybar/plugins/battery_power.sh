#!/bin/bash
# battery_power.sh — Utility helper that other plugins source to detect battery state.
# Returns 0 (success/true)  if running on BATTERY power.
# Returns 1 (failure/false) if running on AC/charger power.
#
# Usage:
#   source "$(dirname "$0")/battery_power.sh"
#   if on_battery; then ... fi
#
# Why: macOS throttles rendering aggressively when windows are offscreen (App Nap).
# To complement this, sketchybar plugin scripts self-throttle their poll frequency
# on battery to further reduce CPU wake-ups from bash spawning.

on_battery() {
    # pmset -g batt returns "Now drawing from 'Battery Power'" on battery.
    # Cache result every 10s to avoid repeated pmset calls.
    local CACHE="/tmp/sketchybar_on_battery"
    local NOW
    NOW=$(date +%s)

    if [ -f "$CACHE" ]; then
        local CACHED_TIME CACHED_VAL
        CACHED_TIME=$(awk '{print $1}' "$CACHE" 2>/dev/null)
        CACHED_VAL=$(awk '{print $2}' "$CACHE" 2>/dev/null)
        if [ -n "$CACHED_TIME" ] && [ $((NOW - CACHED_TIME)) -lt 10 ]; then
            [ "$CACHED_VAL" = "1" ] && return 0 || return 1
        fi
    fi

    if pmset -g batt 2>/dev/null | grep -q "'Battery Power'"; then
        echo "$NOW 1" > "$CACHE"
        return 0
    else
        echo "$NOW 0" > "$CACHE"
        return 1
    fi
}
