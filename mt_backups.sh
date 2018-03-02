#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

#Numbers of days you want to keep copie of your databases
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
echo 'Stop odoo-server'
# sudo service odoo-server stop
for i in $databases
do
    if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ]; then
        path=/home/jarsa/odoo-9.0/backups/${i}
        date=`date +"%d_%m_%Y_%H_%M_%S"`
        if [ ! -d ${path} ]; then
         echo 'Folder made with' $i
         mkdir -p $path
        fi
        echo 'Start Dumping database' $i
        cd ${path}
        pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
        cp -R /home/jarsa/odoo-9.0/.filestorage/filestore/${i} .
        echo 'DONE DB dumped' $i
        cd /home/jarsa/odoo-9.0/backups/
        tar -cvf - ${i} | gzip -9 > /home/jarsa/odoo-9.0/backups/${i}_${date}.tar.gz
        rm -rf ${i}
    fi
done
echo 'Respaldo Finalizado'
# sudo service odoo-server start
echo 'Start Odoo Server'

# delete files more than 3 days old
find /home/jarsa/odoo-9.0/backups/*.tar.gz -mtime +3 -exec rm {} \;