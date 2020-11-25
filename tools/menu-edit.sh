if [[ $1 =~ ^\/.* ]]       
then
	file=$1
else
	file=$(pwd)/$1
fi
if [[ ! -f $file ]]
then
	echo 'No such file'
	exit 0
fi
${COM3D2_PATH}/tools/menu-edit.exe $file &
