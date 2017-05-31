#!/bin/bash
#Install and update docker version
docker_version=$(docker -v|awk '{print $3}'|awk -F. '{print $1 $2}')
old_docker=`rpm -qa |grep docker`
config_file="/usr/lib/systemd/system/docker.service"
host_ip=`ifconfig eth1 | grep --o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|awk 'NR==1'`
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
sed -i '/^ExecStart/cExecStart=/usr/bin/dockerd --registry-mirror=https://2mcyftno.mirror.aliyuncs.com --insecure-registry '$host_ip':5000' $config_file \
	&& systemctl start docker.service
echo `docker images`
#run docker container
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose && docker-compose -v
if [ $? -eq 0 ]
	then
	{ \
		echo "version: '2'"; \
		echo "services:"; \
		echo "  registry:"; \
		echo "    image: registry:2.4.1"; \
		echo "    ports:"; \
		echo "      - 5000:5000"; \
		echo "    volumes:"; \
		echo "      - images-lib:/var/lib/registry"; \
		echo "    restart: "always""; \
		echo "volumes:"; \
		echo "  images-lib: {}"; \
} | tee docker-compose.yml
		echo "docker-compose install seccess "
		docker pull mysql:5.5.50 && docker tag mysql:5.5.50 $host_ip:5000/v1/mysql:5.5.50
		docker push $host_ip:5000/v1/mysql:5.5.50
	else 
		echo "docker-compose install failed "
fi
