#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

for d in $(cat /home/.backups/contain9.txt)
do
    echo 'Stop container' ${d}
    docker stop ${d}
    echo 'Start container' ${d}
    docker start ${d}
    echo 'Initializating Postgres'
    docker exec -t -u odoo ${d} sudo service postgresql start
    echo 'Stop odoo-server'
    docker exec -t -u odoo ${d} sudo service odoo-server stop
    path=/home/.backups/${d}
    date=`date +"%d%m%Y"`
    if [ ! -d ${path} ]; then
     echo 'Folder made with' ${d}
     mkdir -p ${path}
    fi
     databases=`docker exec -i ${d} psql -l -t | cut -d'|' -f1`
     for i in $databases
     do
        if [ "$i" == "erp-carbotecnia-info" ]; then
             cd $path
             echo 'Start Dumping database' $i
             docker exec -t -u odoo ${d} pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
             echo 'Copying filestore to ' $path
             docker cp ${d}:/home/odoo-9.0/odoo/.local/share/Odoo/filestore/filestore/$i/ $path
        elif [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] && [ "$i" != "erp-carbotecnia-info" ]; then
             cd $path
             echo 'Start Dumping database' $i
             docker exec -t -u odoo ${d} pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
             echo 'Copying filestore to ' $path
             docker cp ${d}:/home/odoo-9.0/.local/share/Odoo/filestore/filestore/$i/ $path
        fi
     done
     cd /home/.backups
     tar -cvf - ${d} | gzip > /home/.backups/${d}_$date.tar.gz
     rm -rf ${d}
     mkdir -p backup9_${date}
     mv ${d}_$date.tar.gz /home/.backups/backup9_${date}
     echo 'Start Odoo Server'
     docker exec -t -u odoo ${d} sudo service odoo-server start
done