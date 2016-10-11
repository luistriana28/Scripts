#!/bin/sh
path=/home/.data/backups/

for file in `find ${path} -mtime +30 -type f -name *.tar.gz`
do
  rm $file
done

exit 0