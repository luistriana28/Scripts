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
path=/Users/Jahkahyah/Downloads
databases=`docker exec -it -u odoo carbotecnia psql -l -t | cut -d'|' -f1`
for i in $databases
echo Prueba de bases $databases
do
        if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
            date=`date +"%d%m%Y_%H%M%N"`
            if [ ! -d ${path}/${i} ]; then
                mkdir ${path}/${i}
            fi
            filename="${path}/${i}/${date}/${i}_${date}.sql"
            echo Dumping $i to $path $i
            docker exec -t -u odoo carbotecnia pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
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
