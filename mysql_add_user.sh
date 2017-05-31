#/bin/bash
#add user to mysql db


passpwd=My_Passw0rd


cat user.txt | while read user
do
#  port=`echo $user |awk '{print $1 }'`
  username=`echo $user |awk '{print $1 }'`
  pwd=`echo $user |awk '{print $1 }'`
#  db=`echo $user |awk '{print $4 }'`
#  echo 'port='$port';username='$username';pwd='$pwd';db='$db

/usr/bin/mysql -uroot -h 192.168.1.50 -p$passpwd -P 3310 -e "
use mysql;
GRANT  alter,SELECT,INSERT,UPDATE,DELETE ON JiuYangPErp.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON _JiuYangPErp.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON __JiuYangPErp.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON JiuYangPErp_.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON JiuYangPErp__.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON JiuYang__.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON jycms.* TO '$username'@'%' IDENTIFIED BY '$pwd';
GRANT  SELECT,INSERT,UPDATE,DELETE ON WechatOA.* TO '$username'@'%' IDENTIFIED BY '$pwd';
flush privileges;
"

done
