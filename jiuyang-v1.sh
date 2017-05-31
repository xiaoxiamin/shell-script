#!/bin/bash
#Install and update docker version
docker_version=$(docker -v|awk '{print $3}'|awk -F. '{print $1 $2}')
old_docker=`rpm -qa |grep docker`
config_file="/usr/lib/systemd/system/docker.service"
docker -v 
if [ $? -ne 0 ] || [ $docker_version -lt 112 ]
	then
        	rpm -e $old_docker
        		if [ -s $config_file ]
                		then    rm -f $config_file
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
sed -i '/^ExecStart/cExecStart=/usr/bin/dockerd --registry-mirror=https://2mcyftno.mirror.aliyuncs.com --insecure-registry 192.168.1.50:5000' $config_file \
	&& systemctl start docker.service
        if [ $? -eq 0 ]
                then    echo "registry and accelerator configure seccess !"
                        docker pull 192.168.1.50:5000/xiamin/openresty:v1 \
		&&	docker pull 192.168.1.50:5000/xiamin/php:v1 \
		&&	docker pull 192.168.1.50:5000/xiamin/mysql:v1 \
		&&	docker pull fluent/fluentd \
		&&	echo `docker images`
			if [ $? -eq 0 ]
				then	echo "docker images pull seccess"
				else 	echo "docker images pull failed"
				exit 1
			fi
               else    echo "registry and accelerator configure failed !"
        fi
#create network and volumes
docker network create -d bridge frontend && docker network create -d bridge backend \
&& docker volume create --name file-data && docker volume create --name mysql-data && docker volume create --name fluentd-log \
if [ $? -eq 0 ];then echo "docker network and volumes create seccess";else echo "docker network and volumes create failed!";exit 1;fi
#run fluentd container Collection logs
docker run -d -p 24224:24224 --name fluentd -e TZ=Asia/Shanghai --restart=always -v fluentd-log:/fluentd/log fluent/fluentd \
#run mysql container
&& docker run -d -p 3306:3306 --name mysql --network backend -v mysql-data:/var/lib/mysql --restart=always -e TZ=Asia/Shanghai -e MYSQL_ROOT_PASSWORD=jiuyang1205 --log-driver=fluentd --log-opt fluentd-address=192.168.1.50:24224 --log-opt tag="docker.{{.Name}}" 192.168.1.50:5000/xiamin/mysql:v1 \
#run php container
&& docker run -d --name php -v file-data:/var/www/html/JiuYangPErp/public/files -e TZ=Asia/Shanghai --network backend --network frontend --restart=always --log-driver=fluentd --log-opt fluentd-address=192.168.1.50:24224 --log-opt tag="docker.{{.Name}}" 192.168.1.50:5000/xiamin/php:v1 \
#run nginx container
&&  docker run -d --name nginx -p 80:80 -v file-data:/var/www/html/JiuYangPErp/public/files -e TZ=Asia/Shanghai --network frontend --restart=always --log-driver=fluentd --log-opt fluentd-address=192.168.1.50:24224 --log-opt tag="docker.{{.Name}}" 192.168.1.50:5000/xiamin/openresty:v1
if [ $? -eq 0 ];then echo "docker container runing ...";else echo "docker container start failed !";fi
