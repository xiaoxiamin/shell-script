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
        	chmod +x /usr/src/docker.sh && sh /usr/src/docker.sh && docker -v
        		if [ $? -eq 0 ]
                		then    echo "docker install seccess!"
					rm -f /usr/src/docker.sh
                		else    echo "docker install failed !"
					exit 1
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
		&&	docker pull 192.168.1.50:5000/xiamin/mysql:v1
			if [ $? -eq 0 ]
				then	echo "docker images pull seccess"
				else 	echo "docker images pull failed"
				exit 1
			fi
               else    echo "registry and accelerator configure failed !"
        fi
echo `docker images`
#run docker container
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose && docker-compose -v
if [ $? -eq 0 ]
	then
		 echo "Docker-compose installation seccess"
	else 
		echo "Docker-compose installation failed now by another way to install, please wait.................."
	     yum -y install python wget && wget https://pypi.python.org/packages/e7/a8/7556133689add8d1a54c0b14aeff0acb03c64707ce100ecd53934da1aa13/pip-8.1.2.tar.gz --no-check-certificate && tar zxvf pip-8.1.2.tar.gz && cd pip-8.1.2 && python setup.py install && cd ../ && pip install docker-compose
	if [ $? -eq 0 ] ; then echo "docker-compose installation seccess";rm -rf pip-8.1.2.tar.gz ; chmod +x /usr/bin/docker-compose ; else echo "error: docker-compose installation failed" ; exit 1 ; fi
fi
#create network and volume 
docker network create -d bridge frontend && docker network create -d bridge backend \
&& docker volume create --name file-data && docker volume create --name mysql-data 
if [ $? -eq 0 ];then echo "docker network and volumes create seccess";else echo "docker network and volumes create failed!";exit 1;fi
#create docker-compose file 
{ \
	echo "version: '2'"; \
	echo "services:"; \
	echo "  openresty:"; \
	echo "    image: 192.168.1.50:5000/xiamin/openresty:v1"; \
	echo "    depends_on:"; \
	echo "      - php"; \
	echo "    networks:"; \
	echo "      - frontend"; \
	echo "    volumes:";\
	echo "	    - file-data:/var/www/html/JiuYangPErp/public/files";\
	echo "    ports:"; \
	echo "      - 80:80"; \
	echo "  php:"; \
	echo "    image: 192.168.1.50:5000/xiamin/php:v1"; \
	echo "    networks:"; \
	echo "      - frontend"; \
	echo "      - backend"; \
        echo "    volumes:";\
        echo "      - file-data:/var/www/html/JiuYangPErp/public/files";\
	echo "  mysql:"; \
	echo "    image: 192.168.1.50:5000/xiamin/mysql:v1"; \
	echo "    environment:"; \
	echo "      MYSQL_ROOT_PASSWORD: jiuyang1205"; \
	echo "    networks:"; \
	echo "      - backend"; \
	echo "    volumes:";\
	echo "	    - mysql-data:/var/lib/mysql";\
	echo "    ports:"; \
	echo "      - 3306:3306"; \
	echo "networks:"; \
	echo "  frontend:"; \
	echo "  backend:"; \
	echo "volumes:";\
	echo "  mysql-data: {}";\
	echo "    exteranl: true";\
	echo "  file-data: {}";\
	echo "    exteranl: true";\
} | tee docker-compose.yml
docker-compose up -d 
if [ $? -eq 0 ]; then echo "Container is runing!";else echo "error: docker-compose failure!";fi
