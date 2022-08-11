args=( "${@}" )
divider========================================
divider=$divider$divider

verifyUsers_dbFile(){
	if ! [[ -e ../data/users.db ]]
	then
		declare -l createFileOption='y'
		echo
		echo "The file users.db doesn't exist, Would you like to create it?[Y/n]: "
		read createFileOption
		if [[ $createFileOption = n ]]
		then 
			exit
		else
			touch ../data/users.db
			echo "users.db was created in ../data/"
		fi
	fi
}


addUser(){
	verifyUsers_dbFile
	echo
	declare  username=''
	declare  rol=''
	echo -n  "Type the username: "
	read username
	until [[ $username =~ ^[A-Za-z]+$  ]]
	do
			echo -n "Type the username (Latin letters only): "
			read username
	done

	echo -n  "Type the rol: "
	read rol
	until [[  $rol =~ ^[A-Za-z_]+$ ]]
	do
		echo -n "Type the rol (Latin letters only): "
		read rol
	done
	echo $username,$rol >> ../data/users.db
	echo "User added!"
	echo
}


showManual(){
	width=40
	tableFormat="\n %-10s %s\n"
	echo
	echo "You need to specify  one of the following arguments"
	echo
	printf "$tableFormat"\
	Argument Description
	printf "%$width.${width}s\n" "$divider"
	printf "$tableFormat"\
	add "Adds an user to the DB."\
	backup "Generates a backup of the file users.db (if it exist)."\
	find "Shows the coincidences given an username."\
	help "Describes the possible actions you can perform."\
	list "Prints the content of the users.db file."\
	"" "--inverse displays the list inverted."\
	restore "Takes the latest db backup (if it exist) and load it into the DB."
	echo
}


createBackup(){
	verifyUsers_dbFile
	cat ../data/users.db > ../data/$(date +%y%m%d)-users.db.backup
	echo "Backup generated!"
}


restoreFromBackup(){
	verifyUsers_dbFile
	backupFilesSize=$( ls ../data/ | grep backup | wc -l )
	if [[ $backupFilesSize  < 1 ]]
	then
		printf "\n%s\n\n" "No backup file found"
		exit
	elif [[ $backupFilesSize = 1  ]]
	then
		filename=$( ls ../data/ | grep backup )
		cat ../data/$filename > ../data/users.db
	else
		declare -i fileDate=0
		declare -i auxDate=0 
		for file in $( ls ../data/ | grep backup )
		do
			auxDate=${file:0:6}
			if [[ $auxDate > $fileDate  ]]; then
				fileDate=auxDate
			fi
		done
		cat ../data/$fileDate-users.db.backup > ../data/users.db
		echo "Data base restored"
		echo
	fi
}

find(){
	verifyUsers_dbFile

	declare -l username=''
	declare -l auxUsername=''
	declare -i header=0
	coma=','
	width=38
	tableFormat=" %-20s %s\n"

	echo -n "Type the username to look for: "
	read username
	echo
	until [[ $username =~ ^[A-Za-z]+$ ]]
	do
		echo -n "Type the username (latin letters only): "
		read username
	done
	while read -r line
	do
		rol="${line#*$coma}"
		index=$(( ${#line} - ${#rol} - 1 ))
		auxUsername="${line:0:index}"
		if [[ $auxUsername = $username  ]]; then
			if [[ $header = 0 ]]; then
				printf "$tableFormat" Username Rol
				printf "%$width.${width}s\n" "$divider"
				header=1
			fi
			printf "$tableFormat" ${line:0:index} $rol
		fi
	done < ../data/users.db
	if [[ $header = 0 ]]; then
		echo "No entries found"
	else
		echo
	fi
}


list(){
	verifyUsers_dbFile

	if ! [[ -s ../data/users.db ]]
	then
		printf "\n%s\n\n" "The file is empty"
		exit
	fi

	if [[ ${args[1]} = "--inverse" ]]
	then
		declare -i counter=$( < ../data/users.db wc -l)
		echo
		tac ../data/users.db | while IFS= read line
		do
			echo "$counter. $line"
			counter=$(( $counter - 1 ))
		done
		echo
	else
		echo
		declare -i counter=1
		while read -r line
		do
			echo "$counter. $line"
			counter+=1
		done < ../data/users.db
		echo
	fi
}


case $1 in
	add) addUser;;
	backup) createBackup;;
	find) find;;
	help) showManual;;
	list) list;;
	restore) restoreFromBackup;;
	*) showManual;;
esac


