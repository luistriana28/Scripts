#!/bin/sh

##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

# Stop OpenERP Server
docker stop odoo-7.0

# Dump DBs
path=/home/odoo-7.0/.backups/backups

echo "Backup started"
cat /home/odoo-7.0/.backups/db.txt | while read i
do
    date=`date +"%d%m%Y_%H%M%N"`
    if [ ! -d ${path}/${i} ]; then
        mkdir ${path}/${i}
    fi
    filename="${path}/${i}/${i}_${date}.sql"
    pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
    echo "dump of ${i} created on ${date}"
    gzip ${filename}
    echo "backup compress ${i}"
done

echo "Backup end"

# Start OpenERP Server
docker start odoo-7.0