#!/bin/bash
# 🌀 Spiral Forge AUTO: Pulls latest ChatGPT message, runs full pipeline

cd ~/spiral-forge || exit

TODAY=$(date +%Y-%m-%d)
PROMPT_FILE="prompts/episode_$TODAY.txt"
LOG_FILE="logs/$TODAY.log"

echo "📡 Auto-start at $(date)" > "$LOG_FILE"

# Find ChatGPT browser tab (MUST be open!)
WIN_ID=$(xdotool search --name "ChatGPT" | head -1)

if [ -z "$WIN_ID" ]; then
    echo "❌ ChatGPT window not found. Is the tab open?" >> "$LOG_FILE"
    exit 1
fi

# Focus, scroll, triple click, copy last message
xdotool windowactivate "$WIN_ID"
xdotool key ctrl+End
sleep 2
xdotool mousemove --window "$WIN_ID" 400 600
xdotool click 1; xdotool click 1; xdotool click 1
sleep 0.5
xdotool key ctrl+c
sleep 1

# Save to prompt file
xclip -selection clipboard -o > "$PROMPT_FILE"
echo "💾 Prompt saved to $PROMPT_FILE" >> "$LOG_FILE"

# Generate video
./generate.sh "$PROMPT_FILE" >> "$LOG_FILE" 2>&1
