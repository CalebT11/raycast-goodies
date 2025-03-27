#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ElevenLabs Status Full Report
# @raycast.mode fullOutput
# @raycast.icon 🛠
# @raycast.packageName ElevenLabs
# Optional parameters:
# @raycast.refreshTime 5m

# Documentation:
# @raycast.description Get's operational status details of all ElevenLabs services
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Create a temporary file for the feed
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the RSS feed and save to temp file
curl -s https://status.elevenlabs.io/feed.rss > "$TEMP_FILE"

# Extract and format incident details
echo -e "\033[36mElevenLabs Status Report\033[0m"
echo -e "\033[36m=======================\033[0m"
echo ""

# Process the XML using Python
python3 -c '
import xml.etree.ElementTree as ET
import re
import sys

# Color codes
CYAN = "\033[36m"
GREEN = "\033[32m"
RED = "\033[31m"
NC = "\033[0m"

# Parse the XML
tree = ET.parse(sys.argv[1])
root = tree.getroot()

# Find all item elements
for item in root.findall(".//item"):
    # Extract title and description
    title = item.find("title").text
    desc = item.find("description").text
    
    # Clean up title
    title = title.replace("![CDATA[", "").replace("]]>", "").replace("<!", "")
    
    # Extract status
    status_match = re.search(r"<b>Status:\s*([^<]+)</b>", desc)
    status = status_match.group(1) if status_match else ""
    
    # Clean description
    desc = re.sub(r"<[^>]+>", "", desc)
    desc = desc.replace("![CDATA[", "").replace("]]>", "")
    
    # Remove status line and clean whitespace
    desc = "\n".join(line.strip() for line in desc.split("\n") if "Status:" not in line and line.strip())
    
    # Colorize status based on keywords
    if re.search(r"\bResolved\b", status):
        status_color = GREEN
    elif re.search(r"\bDegraded\b", status):
        status_color = RED
    else:
        status_color = NC
    
    print(f"{CYAN}📌{NC} {title}")
    print(f"   Status: {status_color}{status}{NC}")
    print(f"   {desc}")
    print("")
' "$TEMP_FILE" 