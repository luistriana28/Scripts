#!/bin/sh
path=/home/backups
logfile=/var/log/$0

rm -f $logfile
for file in `find /home/backups -mtime +2 -type f -name *.tar.gz`
do
  echo "deleting: " $file >> $logfile
  rm $file
done

exit 0