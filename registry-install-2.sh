#!/bin/bash
#The script is install keleiDMS system environment
#Install and update docker version
docker_version=$(docker -v|awk '{print $3}'|awk -F. '{print $1 $2}')
old_docker=`rpm -qa |grep docker`
host_ip="`ifconfig eth1 | grep --o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk 'NR==1'`:24224"
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
sed -i '/^ExecStart/cExecStart=/usr/bin/dockerd --registry-mirror=https://2mcyftno.mirror.aliyuncs.com --insecure-registry 60.205.0.202:5000' $config_file # \
#	&& systemctl start docker.service && systemctl enable docker.service
        if [ $? -eq 0 ]
                then    echo "registry and accelerator configure seccess !"
                        docker pull 60.205.0.202:5000/v1/kelei-nginx:v1 \
		&&	docker pull 60.205.0.202:5000/v1/kelei-fpm:v1 \
		&&	docker pull 60.205.0.202:5000/v1/kelei-cli:v1 \
		&&	docker pull 60.205.0.202:5000/v1/mysql:5.5.50 \
		&&	docker pull 60.205.0.202:5000/v1/fluent/fluentd:v1 \
		&&	echo `docker images`
			if [ $? -eq 0 ]
				then	echo "docker images pull seccess"
				else 	echo "docker images pull failed"
				exit 1
			fi
               else    echo "registry and accelerator configure failed !"
        fi
docker network create -d bridge backend \
&& docker volume create --name file-data && docker volume create --name mysql-data && docker volume create --name fluentd-log 
if [ $? -eq 0 ];then echo "docker network and volumes create seccess";else echo "docker network and volumes create failed!";exit 1;fi
#run fluentd container Collection logs
docker run -d -p 24224:24224 --name fluentd --network backend -e TZ=Asia/Shanghai --restart=always -v fluentd-log:/fluentd/log 60.205.0.202:5000/v1/fluent/fluentd:v1 \
&& docker run -d -p 3306:3306 --name mysql --network backend -v mysql-data:/var/lib/mysql --restart=always -e TZ=Asia/Shanghai -e MYSQL_ROOT_PASSWORD=jiuyang1205 --log-driver=fluentd --log-opt fluentd-address=121.42.14.109:24224 --log-opt tag="docker.{{.Name}}" 60.205.0.202:5000/v1/mysql:5.5.50 \
&& docker run -d --name php -v file-data:/usr/src/myapp/KeleiDMS/public/files -e TZ=Asia/Shanghai --network backend --restart=always --log-driver=fluentd --log-opt fluentd-address=121.42.14.109:24224 --log-opt tag="docker.{{.Name}}" 60.205.0.202:5000/v1/kelei-fpm:v1 \
&& docker run -d --name php-swoole --ulimit nofile=102400:102400 -p 23456:23456 -v file-data:/var/www/html/KeleiDMS/public/files -e TZ=Asia/Shanghai --network backend --restart=always --log-driver=fluentd --log-opt fluentd-address=121.42.14.109:24224 --log-opt tag="docker.{{.Name}}" 60.205.0.202:5000/v1/kelei-cli:v1 \
&&  docker run -d --name nginx -p 80:80 -v file-data:/var/www/html/KeleiDMS/public/files -e TZ=Asia/Shanghai --network backend --restart=always --log-driver=fluentd --log-opt fluentd-address=121.42.14.109:24224 --log-opt tag="docker.{{.Name}}" 60.205.0.202:5000/v1/kelei-nginx:v1
if [ $? -eq 0 ];then echo "docker container runing ...";else echo "docker container start failed !";fi
