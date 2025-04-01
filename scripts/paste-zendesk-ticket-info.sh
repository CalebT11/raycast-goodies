#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste Ticket BLUF
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName ElevenLabs

# Documentation:
# @raycast.description Pastes the current Zendesk ticket number and title from the active Chrome Tab into a BLUF format for Slack.
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

# Get page info from Chrome
if ! pgrep -x "Google Chrome" > /dev/null; then
	echo "❌ Google Chrome is not running"
	exit 1
fi

chrome_data=$(osascript -e '
tell application "Google Chrome"
	set pageUrl to URL of active tab of front window
	set pageTitle to title of active tab of front window
	return pageUrl & "|" & pageTitle
end tell
')

# Extract URL and title
IFS="|" read -r page_url page_title <<< "$chrome_data"

# Check if this is a Zendesk ticket
if [[ ! "$page_url" =~ tickets/([0-9]+) ]]; then
	echo "❌ No Zendesk ticket found in current tab"
	exit 1
fi

# Extract ticket number using bash regex
ticket_number="${BASH_REMATCH[1]}"

# Clean the title (remove ticket number from end)
clean_title="${page_title% (#${ticket_number})}"

# Create the link text
link_text="$clean_title | #$ticket_number"

# Create a proper hyperlink using AppleScript
osascript <<EOF
    set theTitle to "$link_text"
    set theURL to "$page_url"

    # Use NSAttributedString to create a hyperlink
    use framework "Foundation"
    use framework "AppKit"
    
    set attrString to current application's NSMutableAttributedString's alloc()'s initWithString:theTitle
    set urlRange to {location:0, |length|:(count of theTitle)}
    
    attrString's addAttribute:(current application's NSLinkAttributeName) value:(current application's NSURL's URLWithString:theURL) range:urlRange
    
    set pasteboard to current application's NSPasteboard's generalPasteboard()
    pasteboard's clearContents()
    pasteboard's writeObjects:{attrString}
    
    tell application "System Events"
        keystroke "["
        delay 0.1
        keystroke "v" using {command down}
        delay 0.1
        keystroke "]"
    end tell
EOF

echo "✅ Pasted ticket link" 