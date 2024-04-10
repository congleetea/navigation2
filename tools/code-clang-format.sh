#!/usr/bin/env bash
#   Copyright (C) 2024 All rights reserved.
#   FileName      ：code-clang-format.sh
#   Author        ：Li Xuancong
#   Email         ：congleetea@163.com
#   Date          ：2024年03月22日
#   Description   ：

usage() {
	echo "USAGE: "
	echo "     ./code-clang-format.sh code-dir-1 code-dir-2"
	exit 0
}

function echo_info(){
	echo -e "\033[37m $1 \033[0m"
}

function echo_error(){
	echo -e "\033[31m $1 \033[0m"
}

if [ $# -eq 0 ];then
	echo_error "Error, please set directory."
	usage
	exit 0
fi

echo_info "param size: $#"
for dir in $*
do
	echo_info ">>>>>>>>>> format code in directory: $dir"
  if [ v"$dir" = "v" ];then
  	echo "ERROR: please type directory you want to format."
  	usage
  	exit
  fi
  find $dir -name "*.hpp" -o -name "*.h" -o -name "*.cc" -o -name "*.c" -o -name "*.cpp" | xargs clang-format -i
done

