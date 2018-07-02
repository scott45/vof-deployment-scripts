#!/bin/bash
pg_dump -F p -f /home/vof/backups/vof-production-db-backup-`date +"%Y"`-`date +"%m"`-`date +"%d"`.sql
echo "Database backup was created:"
ls -lh /home/vof/backups
# prune old backups
find /home/vof/backups -maxdepth 1 -mtime +14 -name "*.sql" -exec rm -rf '{}' ';'