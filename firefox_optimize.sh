#!/bin/sh
# I do not in any way take credit for this script. 
# I do not recall who created this, but I found it, and find it highly useful

for f in ~/.mozilla/firefox/*/*.sqlite; do sqlite3 $f 'VACUUM;'; done
