#!/bin/bash
FILE1=/etc/udev/rules.d/70-persistent-net.rules
FILE2=/etc/sysconfig/network-scripts/ifcfg-eth0
echo "Now start configuring the network!........................................."
read -p "input mac :" new_mac
echo "new mac is $new_mac"
mac1=`grep -v "^#" $FILE1 | egrep '[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}' | tail -2 | head -1 | awk -F '"' '{print $8 }'`
mac2=`egrep '[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}' $FILE2 |awk -F '"' '{print $2}'`
sed -i "s/$mac1/$new_mac/g" $FILE1 && sed -i "s/$mac2/$new_mac/g" $FILE2 && echo "change success!" || echo "change error"
sed -i '13d' $FILE1
sed -i 's/eth0/eth1/g' $FILE2
mv /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1 
echo "restart network ......"
service network restart
ping baidu.com -c 5
if [ $? -eq 0 ]
then echo "network Configuration success !"
else echo "network Configuration fail !"
        exit 0
fi
echo "please click on the install enhancements !!"
mount /dev/cdrom /mnt
if [ -s /mnt ]
then echo "mount success!"
else echo "mount faild!!!"
fi
cd /mnt
./VBoxLinuxAdditions.run
lsmod |grep vboxsf
if [ $? -eq 0 ]
then echo "install enhancenments success!!"
else echo "install enhancenments faild!!"
fi
cd ..
mount -t vboxsf Projects /mnt
if [ $? -eq 0 ]
then echo "mount success!! please input project in /mnt"
else echo "mount faild !"
fi
echo "bye!"
