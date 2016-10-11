#!/bin/sh

##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

# Stop OpenERP Server
sudo service odoo-server stop

# Dump DBs
path=/home/odoo-9.0/.data/backups
f9=/home/odoo-9.0/odoo/.local/share/Odoo/filestore/filestore
logfile=/home/odoo-9.0/.data/logs/backup.log

echo "Backup started"  >> ${logfile}
echo "Backup started"
cat /home/odoo-9.0/.data/db.txt | while read i
do
        if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
            date=`date +"%d%m%Y_%H%M%N"`
            if [ ! -d ${path}/${i} ]; then
                mkdir ${path}/${i}
            fi
            mkdir ${path}/${i}/${date}
            if [ -d ${f9}/${i} ]; then
                cp -r ${f9}/${i} ${path}/${i}/${date}
                echo "filestore of ${i} created on ${date}"
                echo "filestore of ${i} created on ${date}" >> ${logfile}
            fi
            filename="${path}/${i}/${date}/${i}_${date}.sql"
            pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
            echo "dump of ${i} created on ${date}"
            echo "dump of ${i} created on ${date}" >> ${logfile}
            cd ${path}/${i}
            tar -cf - ${date} | gzip > ./${i}_${date}.tar.gz
            echo "backup compress ${i}"
            echo "backup compress ${i}" >> ${logfile}
            rm -rf ${path}/${i}/${date}
        fi
done

echo "Backup end"
echo "Backup end"  >> ${logfile}

# Start OpenERP Server
sudo service odoo-server start

exit 0