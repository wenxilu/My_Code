#!/bin/sh
. /etc/rc.d/init.d/functions
User_Add_Log_Dir=/var/log
User_Add_Log_File_Name=user_add.log
Virtual_User=virtualuser

Viuser_db_dir=/etc/vsftpd/viruser_db
Viuser_db_txt_file_name=login_user_list.txt
Viuser_db_file_name=login_user_list.db

Viuser_config_dir=/etc/vsftpd/viruser_config




################ auth passwd
function Menu_1() {
 cat <<EOF
==============================================

Please select the Number you want!!

1. ADD USER
2. CLEAN USER
3. CHANGE PASSWORD
4. Modify Permissions
5. EXIT


==============================================
EOF




read -p "please enter the number you want : " Num_1
case ${Num_1} in
	1)
		 clear
		while true 
		do
			read -p "please enter the username : " User_Name
			Judge_User_Num=` grep "${User_Name}$" ${Viuser_db_dir}/${Viuser_db_txt_file_name}|wc -l`
			[ ${Judge_User_Num} -ne 0 ]&&{
				echo "The ${User_Name} The user already exists!!!!!!!"
				continue
			}||break
		done
		read -p "please enter the userhome : " User_Home
		Passwd=` echo $RANDOM|md5sum|cut -c1-15`
		Menu_2 ${User_Name} ${User_Home}
		echo -e "${User_Name}\n${Passwd}">>${Viuser_db_dir}/${Viuser_db_txt_file_name}
		[ -d ${User_Home} ]||mkdir -p ${User_Home}
		chown ${Virtual_User}:${Virtual_User} ${User_Home}
		db_load -T -t hash -f ${Viuser_db_dir}/${Viuser_db_txt_file_name} ${Viuser_db_dir}/${Viuser_db_file_name}
		chmod 600 ${Viuser_db_dir}/${Viuser_db_txt_file_name} ${Viuser_db_dir}/${Viuser_db_file_name}
	;;
	
	2)
	 clear
	while true
	do
		read -p "Please enter the name of the user you want to clear : " Clear_User_Name
		[ -e ${User_Add_Log_Dir}/${User_Add_Log_File_Name} ]||{
			 echo -e "Sorry, if ${User_Add_Log_Dir}/${User_Add_Log_File_Name} does not exist, I will not be able to perform cleanup actions"
			 echo -e "Bye!!!!\n"
			exit 2
		}
		 grep ${Clear_User_Name} ${Viuser_db_dir}/${Viuser_db_txt_file_name} &>/dev/null
		[ $? -ne 0 ]&&{
			echo "Sorry,The user already does not exist,Please re-enter !!!!!!!!!!!!!!!!!!!!"
			continue
		}
		Clear_User_Name_Num_1=` cat ${Viuser_db_dir}/${Viuser_db_txt_file_name} -n| grep ${Clear_User_Name}|awk '{print $1}'`		
		Clear_User_Name_Num_2=$((Clear_User_Name_Num_1 + 1))
		#Clear_User_Name_Home_Dir=` grep ${Clear_User_Name} ${User_Add_Log_Dir}/${User_Add_Log_File_Name}|awk '{print $NF}'`
		Clear_User_Name_Home_Dir=`grep local_root ${Viuser_config_dir}/${Clear_User_Name}|awk -F "=" '{print $NF}'`
		 sed -i "${Clear_User_Name_Num_1},${Clear_User_Name_Num_2}d" ${Viuser_db_dir}/${Viuser_db_txt_file_name} &>/dev/null
		 rm -fr ${Viuser_config_dir}/${Clear_User_Name}
		 rm -fr ${Clear_User_Name_Home_Dir}
		 db_load -T -t hash -f ${Viuser_db_dir}/${Viuser_db_txt_file_name} ${Viuser_db_dir}/${Viuser_db_file_name}
		 grep "${Clear_User_Name}" ${Viuser_db_dir}/${Viuser_db_txt_file_name} &>/dev/null
		[ $? -ne 0 ]&&action "User cleanup................ " /bin/true||action "User cleanup................ " /bin/false
		read -p "Do you want to continue cleaning users?  yes|no|exit : " judge_ch
		case ${judge_ch} in
			[yY]|[yY][eE][sS])
				continue
			;;
			
			[nN]|[nN][oO])
				Menu_1
			;;
			exit)
				exit
			;;
		esac
	done
	;;
	
	3)
	 clear
	while true
	do
		read -p "Please enter the name of the user you want to change : " Change_User_Name
		[ -e ${Viuser_db_dir}/${Viuser_db_txt_file_name} ]||{
			 echo -e "Sorry, if ${Viuser_db_dir}/${Viuser_db_txt_file_name} does not exist, I will not be able to perform cleanup actions"
			 echo -e "Bye!!!!\n"
			exit 2
		}
		 grep ${Change_User_Name} ${Viuser_db_dir}/${Viuser_db_txt_file_name} &>/dev/null
		[ $? -ne 0 ]&&{
			echo "Sorry,The user already does not exist,Please re-enter !!!!!!!!!!!!!!!!!!!!"
			continue
		}
		Change_User_Name_Num_1=`cat ${Viuser_db_dir}/${Viuser_db_txt_file_name} -n| grep ${Change_User_Name}|awk '{print $1}'`		
		Change_User_Name_Num_2=`echo "${Change_User_Name_Num_1}+1"|bc`
		Passwd_Orig=` sed -n "${Change_User_Name_Num_2}p" ${Viuser_db_dir}/${Viuser_db_txt_file_name}`
		read -p "Do you want to DIY or want to be RANDOM?   D|R : " Judge_Ch
		case ${Judge_Ch}  in
			D|d)
				read -p "Please enter the password you want to change : " Passwd_Ch
				 sed -i "s#${Passwd_Orig}#${Passwd_Ch}#g" ${Viuser_db_dir}/${Viuser_db_txt_file_name}
				[ $? -eq 0 ]&&action  "Password modification..................." /bin/true||action "Password modification..................." /bin/false
				echo -e "\n ${Judge_Ch} \t\t ${Passwd_Orig} ------- > ${Passwd_Ch}\n"
			;;
			
			R|r)
				New_Passwd_R=`echo $RANDOM|md5sum|cut -c1-15`
				 sed -i "s#${Passwd_Orig}#${New_Passwd_R}#g"  ${Viuser_db_dir}/${Viuser_db_txt_file_name}
				[ $? -eq 0 ]&&action  "Password modification..................." /bin/true||action "Password modification..................." /bin/false
				echo -e "\n ${Judge_Ch} \t\t ${Passwd_Orig} ------- > ${New_Passwd_R}\n"
			;;
		esac
		read -p "Do you want to continue cleaning users?  yes|no|exit : " judge_ch
		case ${judge_ch} in
			[yY]|[yY][eE][sS])
				continue
			;;
			[nN]|[nN][oO])
				Menu_1
			;;
			exit)
				exit
			;;
		esac
	done
	;;
	
	4)
	 clear
	while true
	do
		read -p "Please enter the name of the user you want to change : " Change_User_Name
		[ -e ${Viuser_config_dir}/${Change_User_Name} ]||{
			 echo -e "Sorry, if ${Viuser_config_dir}/${Change_User_Name} does not exist, I will not be able to perform cleanup actions"
			 echo -e "Bye!!!!\n"
			exit 2
		}
		 grep ${Change_User_Name} ${Viuser_db_dir}/${Viuser_db_txt_file_name} &>/dev/null
		[ $? -ne 0 ]&&{
			echo "Sorry,The user already does not exist,Please re-enter !!!!!!!!!!!!!!!!!!!!"
			continue
		}
		User_Home=`grep "local_root" ${Viuser_config_dir}/${Change_User_Name}|awk -F "=" '{print $2}'`
		Menu_2 ${Change_User_Name} ${User_Home}
		read -p "Do you want to continue ?  yes|no|exit : " judge_ch
		case ${judge_ch} in
			[yY]|[yY][eE][sS])
				continue
			;;
			[nN]|[nN][oO])
				Menu_1
			;;
			exit)
				exit
			;;
		esac
	done
	;;
	
	5)
		exit
	;;
	*)
		 clear
		Menu_1
	;;
	
esac

}

############################ privileges all upload_only download_only upload_download_only
function Menu_2() {
Viuser_config_name=$1
User_Home_Ch=$2
echo "============= ${User_Home_Ch}"
 cat <<EOF
==============================================

Please select the permissions you want!!
1. ALL
2. UPLOAD_ONLY
3. DOWNLOAD_ONLY
4. UPLOAD_DOWNLOAD_ONLY
5. BACK MENU ONE

Please enter the Num!!
==============================================
EOF
read -p "please enter the number you want  FOR ${Viuser_config_name}: " Num_2


case ${Num_2} in 
	1)
 cat >${Viuser_config_dir}/${Viuser_config_name}<<EOF
local_root=${User_Home_Ch}
allow_writeable_chroot=YES
virtual_use_local_privs=YES
write_enable=YES
EOF
Priv=ALL
[ -d ${User_Home_Ch} ]||mkdir -p ${User_Home_Ch}
chmod 755 ${User_Home_Ch}
	;;
	
	2)
 cat >${Viuser_config_dir}/${Viuser_config_name}<<EOF
local_root=${User_Home_Ch}
allow_writeable_chroot=YES
virtual_use_local_privs=NO
write_enable=YES
anon_world_readable_only=YES
anon_upload_enable=YES
EOF
Priv=UPLOAD_ONLY
[ -d ${User_Home_Ch} ]||mkdir -p ${User_Home_Ch}
chmod 755 ${User_Home_Ch}
	;;
	
	3)
 cat >${Viuser_config_dir}/${Viuser_config_name}<<EOF
local_root=${User_Home_Ch}
allow_writeable_chroot=YES
virtual_use_local_privs=NO
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=NO
EOF
Priv=DOWNLOAD_ONLY
#echo "========================= ${User_Home}"
[ -d ${User_Home_Ch} ]||mkdir -p ${User_Home_Ch}
chmod a-w ${User_Home_Ch}
	;;

	4)
 cat >${Viuser_config_dir}/${Viuser_config_name}<<EOF
local_root=${User_Home_Ch}
allow_writeable_chroot=YES
virtual_use_local_privs=NO
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
EOF
Priv=UPLOAD_DOWNLOAD_ONLY
[ -d ${User_Home_Ch} ]||mkdir -p ${User_Home_Ch}
chmod 755 ${User_Home_Ch}
	;;
	
	5)	
		clear
		Menu_1
	;;
	
	*)
		clear
		Menu_2 ${Viuser_config_name} ${User_Home_Ch}
	;;
esac
}

function main() {
while true
do
	 clear
	Menu_1

	############### Check info
	User_Name_Check=`tail -2 ${Viuser_db_dir}/${Viuser_db_txt_file_name}|sed -n '1p'`
	User_Passwd_Check=`tail -2 ${Viuser_db_dir}/${Viuser_db_txt_file_name}|sed -n '2p'`
	 clear
	 echo -e "`date +%F-%T`\t${User_Name_Check}\t${User_Passwd_Check}\t${User_Home}\t${Priv}\n"
	 echo -e "`date +%F-%T`\t${User_Name_Check}\t\t${User_Passwd_Check}\t\t${User_Home}\t${Priv}">>${User_Add_Log_Dir}/${User_Add_Log_File_Name}
	read -p "Do you want to continue adding users? yes|no : " judge_ch
	case ${judge_ch} in
		[yY]|[yY][eE][sS])
			continue
		;;
		
		[nN]|[nN][oO])
			exit
		;;
	esac
done

}

main

