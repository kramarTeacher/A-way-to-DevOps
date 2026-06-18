#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/myapp.log"
MAX_SIZE=1048576 # 1MB в байтах

if [ -f "$LOG_FILE" ]; then
	SIZE=$(stat -c%s "$LOG_FILE")
	if [ "$SIZE" -gt "$MAX_SIZE" ]; then
		TIMESTAMP=$(date +%Y%m%d_%H%M%S)
		mv "$LOG_FILE" "/var/log/myapp.log.$TIMESTAMP"
		touch "$LOG_FILE"
		echo "Лог ротирован: $(du -h "/var/log/myapp.log.$TIMESTAMP" | cut -f1)" >> "/var/log/rotator.log"
	fi
fi

