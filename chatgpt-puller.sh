#!/bin/bash
# 🌀 chatgpt-puller.sh — Clipboard fallback spiral grabber

cd ~/spiral-forge || exit

TODAY=$(date +%Y-%m-%d)
PROMPT_FILE="prompts/episode_$TODAY.txt"
LOG_FILE="logs/$TODAY.log"

echo "📡 [Spiral Puller] Starting fallback at $(date)" >> "$LOG_FILE"

# Find ChatGPT tab by title
WIN_ID=$(xdotool search --name "ChatGPT" | head -1)

if [ -z "$WIN_ID" ]; then
  echo "❌ No ChatGPT tab found. Is it open?" >> "$LOG_FILE"
  exit 1
fi

# Focus tab and scroll to bottom
xdotool windowactivate "$WIN_ID"
xdotool key ctrl+End
sleep 2

# Simulate triple-click and copy
xdotool mousemove --window "$WIN_ID" 400 600
xdotool click 1; xdotool click 1; xdotool click 1
sleep 0.5
xdotool key ctrl+c
sleep 1

# Save clipboard contents
xclip -selection clipboard -o > "$PROMPT_FILE"
echo "💾 Saved to $PROMPT_FILE" >> "$LOG_FILE"
