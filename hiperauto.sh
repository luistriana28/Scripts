#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
for i in $databases
do
    if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ]; then
        path=/home/triana/backups/${i}
        date=`date +"%d_%m_%Y_%H_%M"`
        if [ ! -d ${path} ]; then
         echo 'Folder made with' $i
         mkdir -p $path
        fi
        echo 'Start Dumping database' $i
        cd ${path}
        cp -R /home/triana/.local/share/Odoo/filestore/filestore/${i} .
        pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
        echo 'DONE DB dumped' $i
        cd /home/triana/backups
        tar -cvf - ${i} | gzip -9 > /home/triana/backups/${i}_${date}.tar.gz
        rm -rf ${i}
    fi
done
echo 'Respaldo Finalizado'
#sudo service odoo-server start
# echo 'Start Odoo Server'
