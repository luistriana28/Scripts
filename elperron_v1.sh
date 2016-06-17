#!/bin/sh

##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

# Stop OpenERP Server
#docker stop odoo-8.0
#docker stop odoo-9.0-community
#docker stop odoo-9.0-enterprise

# Dump DBs
path=/home/postgres_backups
f8=/home/odoo-8/.local/share/Odoo/filestore
f9=/home/odoo-9/.filestorage/filestore
f9e=/home/docker/volumes/fbff9a950acdc80250860f728dcfb6279a2380efdc6ee601f0b628a3f8f8fd6d/_data/filestore
databases=`docker exec -it -u postgres db psql -l -t | cut -d'|' -f1`
for i in $databases
do
        if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
            date=`date +"%d%m%Y_%H%M%N"`
            if [ ! -d ${path}/${i} ]; then
                mkdir ${path}/${i}
            fi
            mkdir ${path}/${i}/${date}
            if [ -d ${f8}/${i} ]; then
                cp -r ${f8}/${i} ${path}/${i}/${date}
            fi
            if [ -d ${f9}/${i} ]; then
                cp -r ${f9}/${i} ${path}/${i}/${date}
            fi
            if [ -d ${f9e}/${i} ]; then
                cp -r ${f9e}/${i} ${path}/${i}/${date}
            fi
            filename="${path}/${i}/${date}/${i}_${date}.sql"
            echo Dumping $i to $path $i
            docker exec -t -u postgres db pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
            cd ${path}/${i}
            tar -cvf - ${date} | gzip > ./${i}_${date}.tar.gz
            rm -rf ${path}/${i}/${date}
        fi
done

# Start OpenERP Server
#docker start odoo-8.0
#docker start odoo-9.0-community
#docker start odoo-9.0-enterprise

exit 0
