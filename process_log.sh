#!/bin/bash

#Backspace is allowed in user interaction
stty erase ^H

read -p "请输入查看的日期，它看起来像'170606'：" day
read -p "请输入通用查询日志文件名，它看起来像'all.log'："log_file
read -p "请输入查看的开始时间：" start_time
read -p "请输入查看的结束时间：" stop_time
sudo awk 'BEGIN {RS= "'$day'" } $1 > "'$start_time'" && $1 < "'$stop_time'"{print RS,$0}' $log_file > $1
awk BEGIN'{RS="Connect"}{print $1}' $2 |uniq -c|sort -n -r
#read -p "请输入你想查看的用户的操作："user
#awk BEGIN'{RS="Connect"}{if [ "$1" = "$user" ];then {print $0};fi }
#awk BEGIN'{RS="Connect"}{if($1=="simin.*");print $0}''
