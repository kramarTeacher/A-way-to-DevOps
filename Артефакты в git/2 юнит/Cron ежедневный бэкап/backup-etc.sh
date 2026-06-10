#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/var/backups"
BACKUP_FILE="$BACKUP_DIR/etc-$DATE.tar.gz"

# Создаем бэкап
tar -czf "$BACKUP_FILE" /etc/ 2>/dev/null

# Удаляем старые бэкапы (старше 30 дней)
find "$BACKUP_DIR" -name "etc-*.tar.gz" -mtime +30 -delete

echo "Backup created: $BACKUP_FILE"
