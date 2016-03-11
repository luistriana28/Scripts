#!/bin/sh

##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

# Stop OpenERP Server
docker stop odoo-8

# Dump DBs
path=/home/postgres_backups
databases=`docker exec -it -u postgres db psql -l -t | cut -d'|' -f1`
for i in $databases
do
        if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
        	date=`date +"%d%m%Y_%H%M%N"`
            if [ ! -d ${path}/${i} ]; then
              mkdir /home/postgres_backups/${i}
            fi
            filename="${path}/${i}/${i}_${date}.sql"
            echo Dumping $i to $path $i
            docker exec -t -u postgres db pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
            gzip $filename      	
                
        fi
done

# Start OpenERP Server
docker start odoo-8

exit 0
