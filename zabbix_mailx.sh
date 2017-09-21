#!/bin/bash
#export.UTF-8 //解决发送的中文变成了乱码的问题
FILE=/tmp/mailtmp.txt
echo "$3" >$FILE
dos2unix -k $FILE //解决了发送的邮件内容变成附件的问题。
/bin/mail -s "$2" $1 < $FILE
