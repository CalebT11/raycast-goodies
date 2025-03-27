#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check YouTube Availability
# @raycast.mode fullOutput
# @raycast.packageName ElevenLabs
# @raycast.icon 🎥
# @raycast.argument1 { "type": "text", "placeholder": "Dirty Link Dump" }

# Documentation:
# @raycast.description Checks if YouTube links in the selected text are available, private, or region-restricted
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Ensure yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
  echo "❌ yt-dlp not installed! Please install it first: brew install yt-dlp"
  exit 1
fi

# Get text from command argument
input_text="$1"

# Extract unique YouTube links using grep - now properly handles URL endings
video_urls=$(echo "$input_text" | grep -oE "https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[a-zA-Z0-9_-]+(\?[^ \n]*)?")

# Debug output
echo "Extracted URLs:"
echo "$video_urls"
echo "-------------------"

# Check if there are any URLs
if [[ -z "$video_urls" ]]; then
  echo "No YouTube links found in the selected text."
  exit 0
fi

# Function to check video status
check_video() {
  local url=$1
  output=$(yt-dlp --get-title --get-url --dump-json "$url" 2>&1)
  
  if echo "$output" | grep -q "This video is private"; then
    echo "❌ Private: $url"
  elif echo "$output" | grep -q "Video unavailable"; then
    echo "❌ Unavailable: $url"
  elif echo "$output" | grep -q "ERROR: [A-Za-z ]*Geo-restricted"; then
    echo "❌ Region Restricted: $url"
  elif echo "$output" | grep -q "ERROR:"; then
    echo "❌ Error checking video: $url"
  else
    echo "✅ Available: $url"
  fi
}

# Iterate through video URLs and check their status
echo "$video_urls" | while read -r url; do
  check_video "$url"
done
