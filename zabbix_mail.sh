#!/bin/bash
# use mailx to send mail
# 20170725 wenxl  w
# PATH

data_info="$3"
title="$2"
address="$1"
echo "${data_info}" >/tmp/zabbix_mail.log
dos2unix /tmp/zabbix_mail.log >/dev/null 2>&1
cat /tmp/zabbix_mail.log | mail -s "${title}" "${address}"
