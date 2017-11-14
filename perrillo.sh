#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

for d in $(cat /home/c910.txt)
do
    echo 'Stop odoo-server' ${d}
    docker exec -t -u 1000 ${d} sudo service odoo-server stop
    path=/home/backups/${d}
    date=`date +"%d_%m_%Y_%H_%M_%S"`
    if [ ! -d ${path} ]; then
     echo 'Folder made with' $d
     mkdir -p $path
    fi
     databases=`docker exec -i -u 1000 ${d} psql -l -t | cut -d'|' -f1`
     for i in $databases
     do
         if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ]; then
             echo 'Start Dumping database' $i
             cd ${path}
             docker exec -t -u 1000 ${d} pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
             docker cp ${d}:/home/.local/share/Odoo/filestore/filestore/${i} .
             echo 'DONE DB dumped' $i
         fi
     done
     cd /home/backups/
     tar -cvf - ${d} | gzip -9 > /home/backups/${d}_${date}.tar.gz
     rm -rf ${d}
     echo 'Respaldo Finalizado'
     docker exec -t -u 1000 ${d} sudo service odoo-server start
     echo 'Start Odoo Server'
done