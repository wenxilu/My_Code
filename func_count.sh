#!/bin/bash
Change_Calculation() {
Sign=$1
Values_Do=$2
K=1024
M=1048576
G=1073741824
T=1099511627776
case ${Sign} in
        big)
                for Unit in M G T
                do
                  expr ${Values_Do} + 1 &>/dev/null
                  [ $? -eq 0 ] || {
                  echo  ${Values_Do}
                  break
                  }

                  M_Unit_Values=`echo "${Values_Do}/${!Unit}"|bc`
                  if [ ${M_Unit_Values} -gt 1024 ];then
                         continue
                  else
                         The_Answer=`echo "scale=5;${Values_Do}/${!Unit}"|bc`
                         echo ${The_Answer}${Unit}
                         break
                  fi
                done
        ;;

        small)
                Unit_L=`echo ${Values_Do}|sed -n 's#\(.*\)\(.\)#\2#pg'`
                Unit_S=`echo ${Values_Do}|sed -n 's#\(.*\)\(.\)#\1#pg'`

		

                The_Answer=$(echo "scale=5;${Unit_S}*${!Unit_L}"|bc)
                F_spot=`echo ${The_Answer}|awk -F "." '{print $1}'`
                L_spot=`echo ${The_Answer}|awk -F "." '{print $2}'`
		if [ ! -z ${L_spot} ];then
               		if [ ${L_spot} -ge 5 ];then
                       		echo $((F_spot + 1))
               		else
                       		echo ${The_Answer}
               		fi	
		else
			echo ${The_Answer}		
		fi
        ;;
esac
}
#Change_Calculation small $1
Change_Calculation $1 $2
