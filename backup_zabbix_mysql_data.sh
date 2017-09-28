#!/bin/bash
mysqldump -uroot -p9fa31d47cf7c55ce33f2  --events -A -x -F --master-data=2 -B|gzip >/home/wenxilu/backup/zabbix/zabbix-`date +%F`.sql.gz
file=$(ls /home/wenxilu/backup/zabbix/|grep $(date -d "1 day ago $(date +%F)" +%F))
if [ -z $file ];then
   exit 
else
   rm "/home/wenxilu/backup/zabbix/$file"
fi
