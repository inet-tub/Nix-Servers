#!/usr/bin/env bash

BASE_DIR="/data"

# Backup all Nix containers
for dir in "$BASE_DIR"/*/"postgresql"; do

    echo "Dumping $dir"
    mkdir -p "$dir/backups"
    chown -R postgres:postgres "$dir/backups"

    container_name=$(echo $dir | cut -d '/' -f 3 | tr '[:upper:]' '[:lower:]')
    if [ "$container_name" = "wiki" ]; then
        container_name="wiki-js"
    fi

    # Check if the container exists
    if ! nixos-container show-ip "$container_name" > /dev/null 2>&1; then
        continue
    fi

    backup_path="$dir/backups/backup.$(date +%Y-%m-%d_%H:%M:%S).sql"
    nixos-container run "$container_name" -- sudo -u postgres pg_dumpall > "$backup_path"

    # Secure the backup
    chown postgres:postgres "$backup_path"
    chmod 600 "$backup_path"

    # Remove old backups
    find "$dir/backups" -type f -mtime +3 -name '*.sql' -delete

done
