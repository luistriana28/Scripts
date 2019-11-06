#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

for d in $(cat /home/triana/containers.txt)
do
    path=/home/triana/backups/${d}
    date=`date +"%d_%m_%Y_%H_%M_%S"`
    if [ ! -d ${path} ]; then
     echo 'Folder made with' $d
     mkdir -p $path
    fi
     databases=`docker exec -i ${d} psql -l -t | cut -d'|' -f1`
     for i in $databases
     do
         if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ]; then
             echo 'Start Dumping database' $i
             cd ${path}
             docker exec -t ${d} pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
             docker cp ${d}:/home/.local/share/Odoo/filestore/filestore/${i} .
             echo 'DONE DB dumped' $i
         fi
     done
     cd /home/triana/backups/
     tar -cvf - ${d} | gzip -9 > /home/triana/backups/${d}_${date}.tar.gz
     rm -rf ${d}
     echo 'Respaldo Finalizado'
done