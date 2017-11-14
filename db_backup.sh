#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################
path=/home/backups
databases=`psql -l -t | cut -d '|' -f1 | sed -e 's/ //g' -e '/^$/d'`
for d in ${database}
do
    echo 'Stop odoo-server' ${d}
    #sudo service odoo-server stop
    path=/home/backups/${d}
    date=`date +"%d_%m_%Y_%H_%M_%S"`
    if [ ! -d ${path} ]; then
     echo 'Folder made with' $d
     mkdir -p $path
    fi
    if [ "$d" != "template0" ] && [ "$d" != "template1" ] && [ "$d" != "postgres" ]; then
            echo 'Start Dumping database' $d
            cd ${path}
            pg_dump ${d} -E UTF-8 -p 5432 -F p -b --no-owner > ${d}_${date}.sql
            cp /home/.local/share/Odoo/filestore/filestore/${d} .
            echo 'DONE DB dumped' $d
    fi
    cd /home/backups/
    tar -cvf - ${d} | gzip -9 > /home/backups/${d}_${date}.tar.gz
    rm -rf ${d}
    echo 'Respaldo Finalizado'
    #sudo service odoo-server start
    echo 'Start Odoo Server'
done