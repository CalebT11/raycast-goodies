#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste as Bullet Points
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔫
# @raycast.packageName ElevenLabs

# Documentation:
# @raycast.description Useful for reformatting Sam's internal tickets back into bullet points for easier reading.
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Get text from clipboard
input_text=$(pbpaste)

# Format the text by adding newlines before bullet points, only if not already present
formatted_text=$(echo "$input_text" | sed 's/\([^-]\)-[[:space:]]/\1\n- /g')

# Paste ticket number at cursor
if [[ -n "$formatted_text" ]]; then
  echo -n "$formatted_text" | pbcopy
  # Simulate Command + V to paste
  osascript -e 'tell application "System Events" to keystroke "v" using command down'
else
  echo "No text found on clipboard."
fi
