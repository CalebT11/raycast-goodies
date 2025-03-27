#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste Zendesk Ticket Number
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName ElevenLabs

# Documentation:
# @raycast.description Get's the current Zendesk ticket number from the active Chrome Tab
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Get active Chrome tab URL
URL=$(osascript -e '
tell application "Google Chrome"
	set tabURL to URL of active tab of front window
end tell')

# Extract ticket number (assuming URL contains /tickets/123456)
TICKET_NUMBER=$(echo "$URL" | grep -oE 'tickets/[0-9]+' | cut -d'/' -f2)

# Paste ticket number at cursor
if [[ -n "$TICKET_NUMBER" ]]; then
  echo -n "$TICKET_NUMBER" | pbcopy
  osascript -e 'tell application "System Events" to keystroke (the clipboard)'
else
  echo "No ticket number found."
fi
