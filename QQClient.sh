#!/bin/bash
qq=$1
server="218.106.117.180"
port="5999"
message=`echo -e "$2\n$3"|od -t x1 -A n -v -w100000 | tr " " %`
#api_url="http://$server:$port/openqq/send_friend_message"
api_url="http://$server:$port/openqq/send_group_message"
parameter="uid=$qq&content=$message"
curl -d $parameter $api_url
