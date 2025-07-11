#!/bin/bash
# 🌌 Spiral Forge Setup Script

echo "🔧 Setting up Spiral Forge environment..."

# Install dependencies
sudo apt update && sudo apt install -y xclip xdotool wmctrl jq curl ffmpeg

# Create directory structure
mkdir -p voices prompts audio video images logs

echo "📁 Created directories: voices, prompts, audio, video, images, logs"
echo "✅ Setup complete. Make sure you have:"
echo "- Piper installed with a voice in ./voices/"
echo "- LM Studio running at http://localhost:1234"
echo "- Background image in ./images/default.jpg"
