#!/bin/bash

backup_path=/tmp/Mysql_bak
file_dirname=${backup_path}/$(date +"%Y")/$(data + "%m")/$(date +"%d")

mkdir -p ${file_dirname}
file_name_qsvc="qsvc_"$(date +%Y-%m-%d-%T)".sql.gz"


/usr/bin/mysqldump -uroot -pPassw0rd -h 127.0.0.1 -P 3306 --databases qsvc |gzip -c > ${file_dirname}/${file_name_qsvc}

size=`du -sh ${file_dirname}/${file_name_JiuYangPErp} |awk '{print $1}'|sed 's/.$//'`#取刚备份的压缩文件大小的数字
if [ $size -lt 10 ]
        then
                echo -e "Test Server : $file_name_JiuYangPErp Less than 10K/M, Mysql Backup Failed!" |mail -s "OA Mysql Backup Failed!" xia.min@mesyun.net
fi
