#!/bin/bash

host=`hostname -i`
mount_dir=`cat /etc/fstab |grep -vE '^$|^#'|awk '{print $2}'|grep ^/.*`
df_dir=`df -Th|grep -vE 'devicemapper|containers'|awk '{if (NR>1) print $NF}'`

for dir in $mount_dir
do
	m_d=`echo $mount_dir |grep $dir`
	if [ "$m_d" != "" ]
	then
	echo -e "\e[1;32m$dir 挂载正常\e[0m"
	else echo -e "\e[1;31m$dir 挂载不存在\e[0m"
	fi
done

#检查磁盘使用率
Disk_Use=`df -h |awk '{print $6"="$5}' | sed '1d' | sed 's/%//g'`
for i in $Disk_Use
do
        Duse=`echo $i |awk -F'=' '{print $2}'`
        if [ $Duse -gt 40 ];then
        	echo -e "\e[1;31m$host \t磁盘使用率异常,目录:${i}%\e[0m"
        fi
done

#检查cpu使用率
Cpu_idle=`top -b -n 1 |grep Cpu |awk -F ',' '{print $4}'|awk '{print $1}'|awk -F '.' '{print $1}'`
if [ $Cpu_idle -lt 50 ]
then
		echo -e "\e[1;31m$host \tCpu 空闲率异常： $Cpu_idle %\e[0m"
else
		echo -e "\e[1;32m$host \tCpu使用率正常\e[0m"
fi

#检查内存空闲率
#Use_Mem=`free -m  |grep Mem |awk '{print $3}'`
#Tot_Mem=`free -m  |grep Mem |awk '{print $2}'`
#Use_rate=`echo "scale=2;$Use_Mem/$Tot_Mem*100"|bc`

Use_rate=`free -m | awk '/Mem:/{print ($4/$2*100)}'|awk -F '.' '{print $1}'`
if [ $Use_rate -le 10 ]
then
		echo -e "\e[1;31m$host \t内存使用率异常， 空闲率为：$Use_rate %\e[0m"
else
		echo -e "\e[1;32m$host \t内存使用率正常\e[0m"
fi
#check network up/down
net=`ip address |grep bond0|grep   "state DOWN" |wc -l`
if [ $net -ge 1 ]
then
  echo -e "\e[1;31m网卡状态异常，请登录--$host--查看 \e[0m"
else
  echo -e "\e[1;32m$host \t主机网卡状态正常\e[0m"
fi


#检查docker存储空间
space=`docker info 2>/dev/null|grep "Data Space Available"|awk -F ':' '{print $2}'`
space_num=`echo $space|awk '{print $1}'`
space_unit=`echo $space |awk '{print $NF}'`

if [ $space_unit == GB ]
then
	if [ `echo $space_num \> 20 |bc ` -eq 0  ]
	then
		echo -e "\e[1;31merror:\e[0m Docker Data Spave Acailable : \e[1;31m\e[1;5m$space\e[0m\e[0m"

	elif [ `echo $space_num \> 30|bc` -eq 0 ]
	then
		echo  -e "\e[1;33mwarning:\e[0m Docker Data Space Available :\e[1;33m$space\e[0m "

	else
		echo -e "Docker Data Space Available :\e[1;32m$space\e[0m"
	fi
else
	echo -e "\e[1;31m Docker 存储空间: $spave 少于1G\e[0m"
fi
