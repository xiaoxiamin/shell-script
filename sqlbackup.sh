#!/bin/bash

backup_path=/tmp/Mysql_bak
file_dirname=${backup_path}/$(date +"%Y")/$(data + "%m")/$(date +"%d")

mkdir -p ${file_dirname}
file_name_qsvc="qsvc_"$(date +%Y-%m-%d-%T)".sql.gz"


/usr/bin/mysqldump -uroot -pPassw0rd -h 127.0.0.1 -P 3306 --databases qsvc |gzip -c > ${file_dirname}/${file_name_qsvc}
