#!/bin/bash

# Radiant Player - Highstorm Test Suite
# "I will protect those who cannot protect themselves... from bugs."

RED='\033[38;5;160m'
GREEN='\033[38;5;121m'
CYAN='\033[38;5;81m'
NC='\033[0m'
BOLD='\033[1m'

BASE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PY="python3 $BASE_DIR/queue.py"
export PYTHONDONTWRITEBYTECODE=1

echo -e "${CYAN}${BOLD}󱐌 INITIALIZING RADIANT TEST SUITE...${NC}\n"

# 1. Syntax Checks
echo -n "  󰑐 Checking Python syntax... "
if python3 -m py_compile "$BASE_DIR/queue.py" >/dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    exit 1
fi

echo -n "  󰑐 Checking Shell scripts... "
for f in "$BASE_DIR"/*.sh; do
    if ! bash -n "$f" >/dev/null 2>&1; then
        echo -e "${RED}FAIL ($f)${NC}"
        exit 1
    fi
done
echo -e "${GREEN}PASS${NC}"

echo -n "  󰑐 Checking Python unit tests... "
if python3 -m unittest discover -s "$BASE_DIR/tests" -p "test_*.py" >/dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    python3 -m unittest discover -s "$BASE_DIR/tests" -p "test_*.py"
    exit 1
fi

# 2. Dependency Checks
echo -e "\n${CYAN}${BOLD}󰓓 CHECKING SURGE BINDINGS (Dependencies)${NC}"
DEPS=("mpv" "spotify_player" "ffprobe" "fzf" "jq" "chafa")
for dep in "${DEPS[@]}"; do
    echo -n "  󱐋 $dep... "
    if command -v "$dep" >/dev/null 2>&1; then
        echo -e "${GREEN}FOUND${NC}"
    else
        echo -e "${RED}MISSING${NC}"
    fi
done

# 3. Core Logic Tests
echo -e "\n${CYAN}${BOLD}󰀻 TESTING CORE LOGIC${NC}"

echo -n "  󱐋 queue.py health... "
if $PY health >/dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}CRASHED${NC}"
fi

echo -n "  󱐋 queue.py list... "
if $PY list >/dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}CRASHED${NC}"
fi

echo -n "  󱐋 Binary cache... "
if [ -f "/tmp/radiant-bin-cache.json" ]; then
    echo -e "${GREEN}EXISTS${NC}"
else
    echo -e "${RED}NOT FOUND${NC}"
fi

# 4. State Validation
echo -n "  󱐋 queue_state.json validity... "
STATE_FILE="$HOME/.config/radiant-player/queue_state.json"
if [ -f "$STATE_FILE" ]; then
    if jq . "$STATE_FILE" >/dev/null 2>&1; then
        echo -e "${GREEN}VALID JSON${NC}"
    else
        echo -e "${RED}CORRUPTED${NC}"
    fi
else
    echo -e "${RED}NOT FOUND${NC}"
fi

echo -e "\n${GREEN}${BOLD}󱐋 ALL TRIALS COMPLETE. JOURNEY BEFORE DESTINATION.${NC}"
