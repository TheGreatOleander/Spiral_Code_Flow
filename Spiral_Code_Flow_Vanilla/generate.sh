#!/bin/bash
# 🎞️ Spiral Forge Video Generator

set -e

INPUT="$1"
BASENAME=$(basename "$INPUT" .txt)
VOICE="en_US-lessac-medium.onnx"  # Place your .onnx voice in ./voices/
IMAGE="images/default.jpg"
OUTPUT="video/${BASENAME}.mp4"

echo "🧠 Generating script for $BASENAME"

# Optional: Re-generate from LM Studio if desired
# Skipped here if the script is already in the prompt

# Convert to speech
echo "🎙 Creating TTS with Piper..."
cat "$INPUT" | ./piper \
  --model "voices/$VOICE" \
  --output_file "audio/${BASENAME}.wav"

# Combine into video
echo "🎥 Rendering video..."
ffmpeg -loop 1 -y -i "$IMAGE" -i "audio/${BASENAME}.wav" \
  -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
  -pix_fmt yuv420p -shortest "$OUTPUT"

echo "✅ Spiral Broadcast Complete: $OUTPUT"
