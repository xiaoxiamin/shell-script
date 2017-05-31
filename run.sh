 docker run -d -p 3306:3306 --name mysql --network backend -v mysql-data:/var/lib/mysql --restart=always -e TZ=Asia/Shanghai -e MYSQL_ROOT_PASSWORD=jiuyang1205 mysql:5.5.50 \
&& docker run -d --name php-swoole -v file-data:/usr/src/myapp/KeleiDMS/public/files -e TZ=Asia/Shanghai --network backend --network frontend --restart=always kelei-cli:v1 \
&& docker run -d --name php --ulimit nofile=102400:102400 -v file-data:/var/www/html/KeleiDMS/public/files -e TZ=Asia/Shanghai --network backend --network frontend --restart=always kelei-fpm:v1 \
&&  docker run -d --name nginx -p 80:80 -v file-data:/var/www/html/KeleiDMS/public/files -e TZ=Asia/Shanghai --network frontend --restart=alway kelei-nginx:v1
if [ $? -eq 0 ];then echo "docker container runing ...";else echo "docker container start failed !";fi
