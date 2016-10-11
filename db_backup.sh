#!/bin/bash

##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

# Stop OpenERP Server
sudo /etc/init.d/odoo-server stop

# Dump DBs
path=/home/odoo-9.0/.data/backups
filestore=/home/odoo-9.0/.local/share/Odoo/filestore/filestore
logfile=/home/odoo-9.0/.local/log/Odoo/backup.log
databases=`psql -l -t | cut -d '|' -f1 | sed -e 's/ //g' -e '/^$/d'`

echo "Backup started"  >> ${logfile}
echo "Backup started"
for i in ${databases};
do
    if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
        date=`date +"%d%m%Y_%H%M%N"`
        if [ ! -d ${path}/${i} ]; then
            mkdir ${path}/${i}
        fi
        mkdir ${path}/${i}/${date}
        if [ -d ${filestore}/${i} ]; then
            cp -r ${filestore}/${i} ${path}/${i}/${date}
            echo "Filestore of ${i} Created on ${date}"
            echo "Filestore of ${i} Created on ${date}" >> ${logfile}
        fi
        filename="${path}/${i}/${date}/${i}_${date}.sql"
        pg_dump -E UTF-8 -p 5432 -F p -b --no-owner > $filename $i
        echo "Dump of ${i} Created on ${date}"
        echo "Dump of ${i} Created on ${date}" >> ${logfile}
        cd ${path}/${i}
        tar -cf - ${date} | gzip > ./${i}_${date}.tar.gz
        echo "Backup Compressed ${i}"
        echo "Backup Compressed ${i}" >> ${logfile}
        rm -rf ${path}/${i}/${date}
    fi
done

echo "Backup end"
echo "Backup end"  >> ${logfile}

# Start OpenERP Server
sudo service odoo-server start

exit 0