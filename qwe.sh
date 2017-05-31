#!/bin/bash
nginx_conf_file=/mnt/data/nginx.conf
date=`date `
echo "$date"
pwd=`pwd`
echo "$pwd"
file=$pwd/test.conf
host_ip=`ifconfig eno1 | grep --o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk 'NR==1'`
sudo sed -i "/server_name/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$host_ip/g" $file

while [ -z $database_name ] && [ -z $value ]
do
read -p "请输入数据库名称：" database_name
echo -e "\033[31m \033[05m  数据库名称不能为空，请重新输入  \033[0m "

read -n 1 -p "数据库名称为$database_name 请确认数据库名称是否正确(y/n): " value
done

if [ "$value" = "y" ]
        then
                echo "正在创建数据库............"
                /usr/bin/mysql -uroot -p$mysql_pass -h$host_ip -P3306 -e"create database $database_name;"
                if [ $? -eq 0 ];then echo "数据库创建成功";else echo "数据库创建失败";exit;fi
        else
                read -p "请重新输入数据库名称：" database_name
                echo "正在创建数据库............"
                /usr/bin/mysql -uroot -p$mysql_pass -h$host_ip -P3306 -e"create database $database_name;"
                if [ $? -eq 0 ];then echo "数据库创建成功";else echo "数据库创建失败";exit;fi
fi
