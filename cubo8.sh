#!/bin/sh
##########################################
## Odoo Backup
## Backup databases: BASE_DE_DATOS
##########################################

for d in $(cat /home/.backups/contain8.txt)
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
        if [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "postgres" ] && [ "$i" != "?" ] && [ "$i" != " " ] ; then
             cd $path
             echo 'Start Dumping database' $i
             docker exec -t -u odoo ${d} pg_dump ${i} -E UTF-8 -p 5432 -F p -b --no-owner > ${i}_${date}.sql
             echo 'Copying filestore to ' $path
             docker cp ${d}:/home/odoo-8.0/.local/share/Odoo/filestore/filestore/$i/ $path
        fi
     done
     cd /home/.backups
     tar -cvf - ${d} | gzip > /home/.backups/${d}_$date.tar.gz
     mv ${d}_$date.tar.gz /home/.backups/${d}
    
     echo 'Start Odoo Server'
     docker exec -t -u odoo ${d} sudo service odoo-server start
done