ri_dir=`pwd`
cd - &>/dev/null
function Print_Dir_File() {
    local Dir_argv New_dir
    Dir_argv=$1
    cd ${Dir_argv}
    if [ ${Dir_argv} == "/" ];then
        New_dir=""
    else
        New_dir="`pwd`"
    fi
#    for list in `ls ${New_dir}`
    ls ${New_dir}|while read line;do
        if [ -d "${line}" ];then
            cd "$line"
            Print_Dir_File "${New_dir}"/"${line}"
            cd ..
        else
            num=`ls -sh "${line}"|grep "^[0-9.]*G|^[0-9.]*T\b"|wc -l`
            if [ $num -eq 1 ];then
                echo "${New_dir}"/"${line}"|sed -e s#"${Ari_dir}"#.#g
            fi
        fi
    done
}
