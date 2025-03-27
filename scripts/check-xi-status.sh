#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ElevenLabs Status
# @raycast.mode inline

# Optional parameters:
# @raycast.packageName ElevenLabs
# @raycast.icon 🛠
# @raycast.argument1 { "type": "text", "placeholder": "View Details", "optional": true }

# Conditional parameters:
# @raycast.refreshTime 1m

# Documentation:
# @raycast.description Get's an operational status count of all ElevenLabs services
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the RSS feed and parse it
FEED=$(curl -s https://status.elevenlabs.io/feed.rss)

# Count active incidents (not resolved)
ACTIVE_COUNT=$(echo "$FEED" | xmllint --xpath "//item[not(contains(description, 'Status: Resolved'))]/title/text()" - 2>/dev/null | wc -l | tr -d '[:space:]')

# Count resolved incidents
RESOLVED_COUNT=$(echo "$FEED" | xmllint --xpath "//item[contains(description, 'Status: Resolved')]/title/text()" - 2>/dev/null | wc -l | tr -d '[:space:]')

if [ "$ACTIVE_COUNT" -gt 0 ]; then
    echo -e "${RED}⚠️ $ACTIVE_COUNT active, $RESOLVED_COUNT resolved${NC}"
else
    echo -e "${GREEN}✅ All services healthy ($RESOLVED_COUNT resolved)${NC}"
fi

# If argument is provided, open the detailed view in Raycast
if [ -n "$1" ]; then
    open "raycast://commands/xi-status-details"
fi 