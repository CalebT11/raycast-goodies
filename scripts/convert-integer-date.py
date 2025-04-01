#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert Integer Date
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "integer date" }
# @raycast.packageName ElevenLabs

# Documentation:
# @raycast.description Convert's Stripe's integer dates into yyyy/mm/dd format
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/CT11

import sys
from datetime import datetime
print(datetime.fromtimestamp(int(sys.argv[1])).strftime('%Y/%m/%d'))

