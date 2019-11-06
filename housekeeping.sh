#!/bin/sh
path=/home/triana/backups
logfile=/var/log/$0

rm -f $logfile
for file in `find $path -mtime +2 -type f -name *.tar.gz`
do
  echo "deleting: " $file >> $logfile
  rm $file
done

exit 0