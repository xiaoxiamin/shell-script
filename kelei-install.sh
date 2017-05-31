#!/bin/bash
#The script is install keleiDMS system environment
docker_version=$(docker -v|awk '{print $3}'|awk -F. '{print $1 $2}')
old_docker=`rpm -qa |grep docker`
docker_config_file="/usr/lib/systemd/system/docker.service"
nginx_config_file="`pwd`/www.conf"
old_server_name=`cat $nginx_config_file |grep "server_name"|awk '{print $2}'|sed 's/;//g'`
read -p "请输入网站域名：" new_server_name
read -n 1 -p "域名为$new_server_name 请确认地址是否正确(y/n): " value
if [ "$value" = "y" ] || [ -s $nginx_conf_file ] 
	then 
		echo "正在进行域名写入............"
		sed -i "s/$old_server_name/$new_server_name/g" $nginx_config_file
		if [ $? -eq 0 ];then echo "域名写入成功";else echo "域名写入失败";fi
	else
		read -p "请重新输入网站域名：" new_servera_name
		sed -i "s/$old_server_name/$new_server_name/g" $nginx_config_file
		if [ $? -eq 0 ];then echo "域名写入成功";else echo "域名写入失败";fi
fi
#Install and update docker version
docker -v 
if [ $? -ne 0 ] || [ $docker_version -lt 112 ]
	then
        	rpm -e $old_docker
        		if [ -s $docker_config_file ]
                		then    rm -f $docker_config_file
        		fi
        	curl http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet > /usr/src/docker.sh
        	chmod +x /usr/src/docker.sh && sh /usr/src/docker.sh && docker -v && rm -f /usr/src/docker.sh
        		if [ $? -eq 0 ]
                		then    echo "docker install seccess!"
                		else    echo "docker install failed !"
        		fi
	else	
		echo  "docker version 1.12,is already up to date!"
fi
#Configure docker environment
sed -i '/^ExecStart/cExecStart=/usr/bin/dockerd --registry-mirror=https://2mcyftno.mirror.aliyuncs.com --insecure-registry 60.205.0.202:5000' $docker_config_file \
	&& systemctl start docker.service && systemctl enable docker.service
        if [ $? -eq 0 ]
                then    echo "registry and accelerator configure seccess !"
			echo "正在下载镜像环境，请耐心等待................."
                        docker pull 60.205.0.202:5000/v1/kelei-nginx:v2 \
		&&	docker pull 60.205.0.202:5000/v1/kelei-fpm:v2 \
		&&	docker pull 60.205.0.202:5000/v1/kelei-cli:v2 \
		&&	docker pull 60.205.0.202:5000/v1/mysql:5.5.50 \
		&&	echo `docker images`
			if [ $? -eq 0 ]
				then	echo "docker images pull seccess"
				else 	echo "docker images pull failed"
				exit 1
			fi
               else    echo "registry and accelerator configure failed !"
        fi
#create docker container network and volume
docker network create -d bridge frontend \
&& docker volume create --name file-data && docker volume create --name mysql-data
if [ $? -eq 0 ];then echo "docker network and volumes create seccess";else echo "docker network and volumes create failed!";exit 1;fi
#running docker container 
docker run -d -p 3306:3306 --name mysql --network frontend -v mysql-data:/var/lib/mysql --restart=always -e TZ=Asia/Shanghai -e MYSQL_ROOT_PASSWORD=P@ssw0rd --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci 60.205.0.202:5000/v1/mysql:5.5.50 \
&& docker run -d --name php -v file-data:/usr/src/myapp/KeleiDMS/public/files -e TZ=Asia/Shanghai --network frontend --restart=always 60.205.0.202:5000/v1/kelei-fpm:v2 \
&& docker run -d --name php-swoole --ulimit nofile=102400:102400 -p 23456:23456 -v file-data:/var/www/html/KeleiDMS/public/files -e TZ=Asia/Shanghai --network frontend --restart=always 60.205.0.202:5000/v1/kelei-cli:v2 \
&&  docker run -d --name nginx -p 80:80 -v file-data:/var/www/html/KeleiDMS/public/files -v $nginx_config_file:/etc/openresty/conf.d/www.conf -e TZ=Asia/Shanghai --network frontend --restart=always 60.205.0.202:5000/v1/kelei-nginx:v2
if [ $? -eq 0 ];then echo "科雷系统环境已经部署完成，请导入数据库后访问域名/ip查看是否正常！";else echo "环境运行失败 !";fi
