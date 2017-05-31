#!/bin/sh
#description: Web Server Automatic Configuration Script for Beta

JiuYangPErp="/mnt/xvdb/www/JiuYangPErp"
apps="$JiuYangPErp/apps"
token_file="$apps/libs/JiuYang/Extensions/Wechats/token.txt"
jsapi_ticket="$apps/libs/JiuYang/Extensions/Wechats/jsapi_ticket.txt"
log="/tmp/beta.log"
date=`date +%Y-%m-%d-%T`

#删除单元测试目录
cd $JiuYangPErp && sudo /bin/rm -rf tests/

#创建缓存目录
sudo mkdir \
$apps/apis/caches \
$apps/bases/caches \
$apps/weixin/caches \
$apps/init/caches \
$apps/qiyeoa/caches 
if [ $? -ne 0 ];then echo -e " $date\nERROR: mkdir caches failed." >> $log ;else echo -e " $date\nSUCCESS: mkdir caches." >> $log ;fi 

#删除git用户组提交的模版文件
sudo rm -rf \
$apps/bases/views/template \
$apps/qiyeoa/views/template \
$apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e " $date\nERROR: delete template failed." >> $log ;fi

#修改apis配置文件
sudo sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127\.0\.0\.1/g" \
$apps/apis/config/config.php && \
sudo sed -i "s/`cat $apps/apis/config/config.php|grep 'username' |awk -F '"' '{print $4}'`/system/g"  \
$apps/apis/config/config.php && \
sudo sed -i "s/`cat $apps/apis/config/config.php|grep 'password' |awk -F '"' '{print $4}'`/jiuyang1205/g" \
$apps/apis/config/config.php && \
sudo sed -i "s/`cat $apps/apis/config/config.php|grep 'dbname' |awk -F '"' '{print $4}'`/JiuYangPErpV2/g" \
$apps/apis/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: apis_config_file configured failed." >> $log ;fi

#修改bases层配置文件
sudo sed -i '/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127\.0\.0\.1/g' \
$apps/bases/config/config.php && \
sudo sed -i "s/`cat $apps/bases/config/config.php|grep 'username' |awk -F "'" '{print $4}'`/system/g" \
$apps/bases/config/config.php && \
sudo sed -i "s/`cat $apps/bases/config/config.php|grep 'password' |awk -F "'" '{print $4}'`/jiuyang1205/g" \
$apps/bases/config/config.php && \
sudo sed -i "s/`cat $apps/bases/config/config.php|grep 'dbname' |awk -F "'" '{print $4}'`/JiuYangPErpV2/g" \
$apps/bases/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: bases_config_file configured failed." >> $log ;fi

#修改consoles配置文件
sudo sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127\.0\.0\.1/g" \
$apps/consoles/config/config.php && \
sudo sed -i "s#`cat $apps/consoles/config/config.php|grep 'username' |awk -F "'" '{print $4}'`#system#g" \
$apps/consoles/config/config.php && \
sudo sed -i "s/`cat $apps/consoles/config/config.php|grep 'password' |awk -F "'" '{print $4}'`/jiuyang1205/g" \
$apps/consoles/config/config.php && \
sudo sed -i "s/`cat $apps/consoles/config/config.php|grep 'dbname' |awk -F "'" '{print $4}'`/JiuYangPErpV2/g" \
$apps/consoles/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: consoles_config_file configured failed." >> $log ;fi

#修改qiyeoa的配置文件
sudo sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127\.0\.0\.1/g" \
$apps/qiyeoa/config/config.php && \
sudo sed -i "s/`cat $apps/qiyeoa/config/config.php|grep 'username' |awk -F '"' '{print $4}'`/system/g" \
$apps/qiyeoa/config/config.php && \
sudo sed -i "s/`cat $apps/qiyeoa/config/config.php|grep 'password' |awk -F '"' '{print $4}'`/jiuyang1205/g" \
$apps/qiyeoa/config/config.php && \
sudo sed -i "s/`cat $apps/qiyeoa/config/config.php|grep 'dbname' |awk -F '"' '{print $4}'`/JiuYangPErpV2/g" \
$apps/qiyeoa/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: qiyeoa_config_file configured failed." >> $log ;fi

#修改微信的配置文件
sudo sed -i "/host/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127\.0\.0\.1/g" \
$apps/weixin/config/config.php && \
sudo sed -i "s/`cat $apps/weixin/config/config.php|grep 'username' |awk -F '"' '{print $4}'`/system/g" \
$apps/weixin/config/config.php && \
sudo sed -i "s/`cat $apps/weixin/config/config.php|grep 'password' |awk -F '"' '{print $4}'`/jiuyang1205/g" \
$apps/weixin/config/config.php && \
sudo sed -i "s/`cat $apps/weixin/config/config.php|grep 'dbname' |awk -F '"' '{print $4}'`/JiuYangPErpV2/g" \
$apps/weixin/config/config.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: weixin_config_file configured failed." >> $log ;fi

#链接文件上传目录
sudo ln -s /mnt/xvdb/www/files $JiuYangPErp/public/files
if [ $? -ne 0 ];then echo -e "$date\nERROR: link files_dir failed." >> $log ;fi

#链接模版目录
sudo ln -s /mnt/xvdb/www/template $apps/bases/views/template && \
sudo ln -s /mnt/xvdb/www/template $apps/qiyeoa/views/template && \
sudo ln -s /mnt/xvdb/www/mobiletemplate $apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e "$date\nERROR: link template_dir failed." >> $log ;fi

#配置dbv
#sudo cp /mnt/xvdb/www/config/config.php $JiuYangPErp/public/dbv/

#项目权限设置
sudo chmod 755 $JiuYangPErp -R
#sudo chmod 777 $JiuYangPErp/public/dbv/data -R
sudo chmod 777 $JiuYangPErp/public/files -R
if [ $? -ne 0 ];then echo -e "$date\nERROR: permission configured failed." >> $log ;fi

#缓存目录权限
sudo chmod 777 \
$apps/apis/caches \
$apps/bases/caches \
$apps/weixin/caches \
$apps/init/caches \
$apps/qiyeoa/caches \
$JiuYangPErp/config/webConfig.php
if [ $? -ne 0 ];then echo -e "$date\nERROR: caches permission configured failed." >> $log ;fi

#模版文件权限
sudo chmod 777 \
$apps/bases/views/template \
$apps/qiyeoa/views/template \
$apps/bases/views/mobiletemplate
if [ $? -ne 0 ];then echo -e "$date\nERROR: template permission configured failed." >> $log;fi

#日志等文件权限
sudo chmod 777 \
$JiuYangPErp/public/jpush.log \
$JiuYangPErp/public/temp/debug.log \
$token_file \
$jsapi_ticket
if [ $? -ne 0 ];then echo -e "$date\nERROR: log_file permission configured failed." >> $log;fi
sudo chown www:www $JiuYangPErp -R
sudo rm -rf $JiuYangPErp/.git
