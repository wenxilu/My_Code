#!/bin/bash

url_list=$1
File_Down=filedown.list

function ncbi_file_down_list() {
    URI=$1
    URL_Values=`echo "${URI}"|awk -F '/' '{print $NF}'|cut -c 1-9`
    echo "# ${URI}" >> ${File_Down}
    curl "https://www.ncbi.nlm.nih.gov/gquery/?term=${URL_Values}"  >> a.html
    File_Down_URL=`grep ftp a.html |awk -F 'href="|">Download' '{print $2}'|sed -e 's#/public/?/ftp#ftp://ftp.ncbi.nlm.nih.gov#g'`
    echo "${File_Down_URL}" >>${File_Down}
    echo -e "\n" >> ${File_Down}
    rm -fr a.html
}

function main() {
    cat ${url_list}|while read list
    do
      ncbi_file_down_list "${list}"
    done
# start down 
    for line in `cat ${File_Down}|grep '^[a-Z]'` 
    do
      dir_name=`echo "${line}"|awk -F / '{print $NF}'`
      mkdir ${dir_name}
      wget -r -nd -c ${line} -P ${dir_name}
    done
}
main
