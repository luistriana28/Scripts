#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################
databases=`export PGPASSWORD='tenolisuperadmin'; psql -l -h app-tenoli-co.celgsgsshoum.us-east-1.rds.amazonaws.com -U tenoliodoo -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
echo 'Stop odoo-server'
sudo service odoo-server stop
for i in $databases
do
    if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "rdsadmin" ]; then
        path=/home/ubuntu/backups/${i}
        date=`date +"%d_%m_%Y_%H_%M_%S"`
        if [ ! -d ${path} ]; then
         echo 'Folder made with' $i
         mkdir -p $path
        fi
        echo 'Start Dumping database' $i
        cd ${path}
        export PGPASSWORD='tenolisuperadmin'; pg_dump -h app-tenoli-co.celgsgsshoum.us-east-1.rds.amazonaws.com -U tenoliodoo -d ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
        cp -R /home/ubuntu/.local/share/Odoo/filestore/filestore/${i} .
        echo 'DONE DB dumped' $i
        cd /home/ubuntu/backups/
        tar -cvf - ${i} | gzip -9 > /home/ubuntu/backups/${i}_${date}.tar.gz
        rm -rf ${i}
    fi
done
echo 'Respaldo Finalizado'
sudo service odoo-server start
echo 'Start Odoo Server'

# delete files more than 3 days old
find /home/ubuntu/backups/*.tar.gz -mtime +3 -exec rm {} \;