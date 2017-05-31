#!/bin/sh
#description: Web Server Automatic Configuration Script for TopCent

#Backspace is allowed in user interaction
stty erase ^H

pwd=`pwd`
JiuYangPErp="$pwd/JiuYangPErp"
apps="$JiuYangPErp/apps"
token_file="$apps/libs/JiuYang/Extensions/Wechats/token.txt"
jsapi_ticket="$apps/libs/JiuYang/Extensions/Wechats/jsapi_ticket.txt"
log="/tmp/beta_install.log"
date=`date +%Y-%m-%d-%T`
ip=`ip a |grep -e "eno" -e "eth" | grep --o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|grep -v "$255"`
mysql_pass="p@ssw0rd456"
files="$pwd/files"
template="$pwd/template"
mobiletemplate="$pwd/mobiletemplate"
nginx_conf_file="/etc/openresty/conf.d/${date}.conf"

#clone project
clear
echo -e "\033[31m \033[05m Project source code download now, please wait......\033[0m"
cd $pwd 
git clone -b release_2.0 ssh://admin@git.mesyun.net:29418/JiuYangPErp.git
if [ $? -eq 0 ];then echo "Project Download success!";else echo "Project Download failed!!!";exit;fi

#re-write namespace and filename
#find $JiuYangTF/* -type f |xargs grep --color -wl "JiuYangPErp" | xargs sed -i 's/JiuYangPErp/JiuyangTF/g'
#if [ $? -eq 0 ];then echo "Namespace rewrite failed!" ;else echo "Namespace rewrite seccuss!";fi
#for file in `find ${JiuYangTF}/* -type f -name "*iu*ang*rp*" -exec ls {} \;`
#	do
#		mv $file `echo $file|sed 's#/JiuYangPErp#/JiuYangTF#g'`
#done

#ip address confirmations
while true
do
	clear
	if [[ "$i" = "Y" || "$i" = "y" ]];then break ;fi
        echo -e "\033[33m Please refer to the given address to enter a valid IP to configure the project: \n \033[31m ${ip} \033[0m\n" 
	read -p "your host ip :" host_ip
	clear
	if [ -z $host_ip ];then echo -e "\033[31m \033[05m ip address cannot be empty!! \033[0m" 
	else
		while true 
		do
			clear
			echo -e " \033[33m The ip address is:  \033[31m\n  $host_ip \033[0m " 
			read -p "please input Y/n:" i
			if [ -z $i ];then echo -e  "\033[31m \033[05m input cannot be empty! \033[0m" 
			elif [[ "$i" = "Y" || "$i" = "y" ]];then break;
			else break
			fi
		done
	fi
done

#Download template files in the current directory
cd $pwd
echo -e "\033[033m Downloading template file...... \033[0m"
wget --no-check-certificate http://perp.mesyun.net/template.tar.gz && \
tar zxvf template.tar.gz && rm -rf template.tar.gz
if [ $? -eq 0 ] && [ -d $template ] && [ -d $mobiletemplate ] ;then echo -e "\033[033m Download template file successfully \033[0m";else echo "Failed to download template file!";exit;fi

#Nginx Configuration Download
echo -e "\033[033m Downloading nginx config file...... \033[0m"
wget --no-check-certificate  http://perp.mesyun.net/template.conf -O $nginx_conf_file
if [ $? -eq 0 ] && [ -f $nginx_conf_file ] ;then echo "Download nginx configuration successfully!";else echo "Failed to download nginx configuration file!";exit;fi

old_server_name=`cat $nginx_conf_file |grep "server_name"|awk '{print $2}'|sed 's/;//g'`
old_root_path=`cat $nginx_conf_file |grep "set"|grep '$root_path' |awk '{print $3}'|awk -F "'" '{print $2}'`
new_root_path="$JiuYangPErp/public"
#old_log_path=`cat $nginx_conf_filed |grep -e "access" -e "error"|awk '{print $2}'|awk -F "/" '{print $NF}'|awk -F '.' '{print $1}'`

#Domain Name Configuration 
while true
do
	clear
        if [[ $value1 = Y || $value1 = y ]];then break;fi
        echo -e "\033[033m please input domain name to nginx server_name \033[0m"
	read -p "domain name:  " new_server_name
        if [ -z $new_server_name ]
                then    echo -e "\033[31m  \033[05m Error: Domain name cannot be empty!!!\033[0m" 
        else
                while true  
                do
                        echo -e "\033[033m  Domian name is: \033[031m  $new_server_name \033[033m \n please enter Y/n to generate the nginx configuration file \033[0m" 
			read -p "    Y/n : " value1
                        if [ -z $value1 ];then echo -e "\033[31m \033[05m  input value cannot be empty!!!\033[0m"
                        elif [[ $value1 = Y || $value1 = y ]];then
                                echo -e "\033[033m  Generating nginx configuration file...... \033[0m"
                                sed -i "s#$old_server_name#$new_server_name#g" $nginx_conf_file && \ 
				sed -i "s#$old_root_path#$new_root_path#g" $nginx_conf_file 
                                if [ $? -eq 0 ];then echo "Domian name write success!";else echo "Domain name write failure!!";exit;fi
                                break
                        else break
                        fi
                done
        fi
done

#Database Configuration
while true 
do
	clear
	if [[ $value2 = Y || $value2 = y ]];then break;fi
	echo -e "\033[033m Please input database name: \033[0m"
	read -p "database name : " database_name
   	if [ -z $database_name ]
        	then echo -e "\033[31m  \033[05m Error: Database name cannot be empty !!! \033[0m"
   	else	
		while true 
		do 
			echo -e "\033[033m Database name: \033[031m $database_name \033[033m Please enter y/n to confirm the database name is correct \033[0m "
			read -p "Y/n : " value2
			if [ -z $value2 ]
                		then echo -e "\033[031m \033[05m input value cannot be empty!!! \033[0m" 
			elif [[ $value2 = Y || $value2 = y ]]
				then echo -e "\033[031m create database......\033[0m "
				mysql -uroot -p$mysql_pass -h$host_ip -e"create database $database_name;"
				if [ $? -eq 0 ];then echo "Create database success!";else echo "Create database failure!";exit;fi
                       		break
			else break
			fi
		done
	fi
done


#remove unit test dir
cd $JiuYangPErp && /bin/rm -rf tests/

#mkdir caches dir
mkdir \
$apps/apis/caches \
$apps/bases/caches \
$apps/weixin/caches \
$apps/init/caches \
$apps/qiyeoa/caches 
if [ $? -ne 0 ];then echo -e " $date\nERROR: mkdir caches failed." >> $log ;else echo -e " $date\nSUCCESS: mkdir caches." >> $log ;fi 

#remove useless template files
rm -rf \
$apps/bases/views/template \
$apps/qiyeoa/views/template \
$apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e " $date\nERROR: delete template failed." >> $log ;fi

# Configure apis config file
sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$host_ip/g" $apps/apis/config/config.php && \
sed -i "s/jiuyang1205/$mysql_pass/g" $apps/apis/config/config.php && \
sed -i "s/JiuYangPErp/$database_name/g" $apps/apis/config/config.php && \
if [ $? -ne 0 ];then echo -e "$date\nERROR: apis_config_file configured failed." >> $log ;fi

#Configure consoles config file
sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$host_ip/g" $apps/consoles/config/config.php && \
sed -i "s/JiuYangPErp/$database_name/g" $apps/consoles/config/config.php
sed -i "s/jiuyang1205/$mysql_pass/g" $apps/consoles/config/config.php

#Configure bases config file
sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$host_ip/g" $apps/bases/config/config.php && \
sed -i "s/jiuyang1205/$mysql_pass/g" $apps/bases/config/config.php && \
sed -i "s/JiuYangPErp/$database_name/g" $apps/bases/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: bases_config_file configured failed." >> $log ;fi

#mkdir and link files dir
mkdir -p $files/avatars $files/apks && \
ln -s $files $JiuYangPErp/public/
if [ $? -ne 0 ];then echo -e "$date\nERROR: link files_dir failed." >> $log ;fi

#link template files
ln -s $template $apps/bases/views/template && \
ln -s $template $apps/qiyeoa/views/template && \
ln -s $mobiletemplate $apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e "$date\nERROR: link template_dir failed." >> $log ;fi

#Project permission configuration
chmod 755 $JiuYangPErp -R
chmod 777 $JiuYangPErp/public/files -R
if [ $? -ne 0 ];then echo -e "$date\nERROR: permission configured failed." >> $log ;fi

#caches permission configuration
chmod 777 \
$apps/apis/caches \
$apps/bases/caches \
$apps/weixin/caches \
$apps/init/caches \
$apps/qiyeoa/caches \
$JiuYangPErp/config/webConfig.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: caches permission configured failed." >> $log ;fi

#template permission configuration
chmod 777 \
$apps/bases/views/template \
$apps/qiyeoa/views/template \
$apps/bases/config/config.php \
$apps/config/enums.php \
$apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e "$date\nERROR: template permission configured failed." >> $log;fi

#logs permission configuration
chmod 777 \
$JiuYangPErp/public/jpush.log \
$JiuYangPErp/public/temp/debug.log \
$token_file \
$jsapi_ticket
if [ $? -ne 0 ];then echo -e "$date\nERROR: log_file permission configured failed." >> $log;fi
chown www:www $JiuYangPErp -R
rm -rf $JiuYangPErp/.git
/usr/local/openresty/nginx/sbin/nginx -s reload

#import sql file
#/usr/bin/mysqldump -uroot -p$pass -h $host_ip --databases JiuYangPErp |gzip -c > ${file_dirname} && \
#mysql -uroot -p$mysql_pass -h $host_ip -P 3306 $database_name < $JiuYangPErp/public/JiuYangPErp.sql
#if [ $? -ne 0 ];then echo -e "$date\nERROR: SQL import and export failed." >> $log
#else echo  -e "数据库导入成功！\n项目配置完成！\n请在浏览器输入域名：$new_server_name 进行初始化配置!"
#fi
echo -e "Project configuration completed!\nPlease enter $new_server_name to initialize configuration in the browser\n bye~ "
