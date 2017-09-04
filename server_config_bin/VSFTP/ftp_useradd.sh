#!/bin/sh
userinfo_file=/home/wenxilu/userinfo/username_info
read -p "Please enter the username :" username
read -p "Please enter the userhome :" userhome
read -p "Yes or No :"  State
case $State in
        [yY]|[yY][eE][sS])
	id ${username} &>/dev/null
	[ $? -ne 0  ]||{
	echo -e "sorry id ${username} exist!!!!\n"
	exit 2
	grep ${username} ${userinfo_file}
	}
        sudo useradd ${username} -s /usr/sbin/nologin -d ${userhome}
	Num=`sudo echo $RANDOM|md5sum|cut -c1-15`
	sudo echo "${username}  ${Num}">>${userinfo_file}
	sudo echo "${username}">>/etc/vsftpd/chroot_list
        sudo echo ${Num}|sudo passwd --stdin ${username}    
	sudo tail -1 ${userinfo_file}
        ;;
        [nN]|[nN][oO])
        exit
        ;;
	
	*)
	echo "sorry !!!!!!!!!!!!!"
	;;
esac
