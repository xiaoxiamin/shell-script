#!/bin/bash
#this is backup script for topcentV2.0

source_dir="/V2.0/dingjia"
backup_path="/backup/topcentV2_codeBackup"
#file_dirname="${backup_path}/$(date +"%m")/$(date +"%d")"
mkdir -p ${file_dirname}
file_name="JiuYangPErpV2_"$(date +"%m-%d-%H")".tar.gz"
#sudo cp -r ${source_code} ${file_dirname}/
cd ${source_dir}
/bin/tar Pzcvf ${backup_path}/${file_name} JiuYangPErp
if [  $? -ne 0 ];then echo -e "$date\nERROR: topcentV2.0 backup failed." >> /tmp/topcentV2.log;fi


#删除7天的备份

sudo find ${backup_path} -type f -mtime +7 -exec rm -f "{}" \;
if [  $? -ne 0 ];then echo -e "$date\nERROR: topcentV2.0 remove 7 days ago failed" >> /tmp/topcentV2.log;fi
~                                                                                                           
