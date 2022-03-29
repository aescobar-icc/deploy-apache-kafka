#!/bin/bash

# author: Adán Escobar
# mail: hello-dev@codeits.cl
# linkedin: https://www.linkedin.com/in/aescobar-ing-civil-computacion/

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37



LOG_PROMP="CODEITS.SH"

Red='\033[0;31m'
Green='\033[0;32m'
BrownOrange='\033[0;33m'
NoColor='\033[0m' # No Color

#FUNCTIONS
function log(){
	echo -e "${Green}[$LOG_PROMP]${BrownOrange} $1 ${NoColor}"
}
function errorlog(){
	echo -e "${Green}[$LOG_PROMP]${Red} $1 ${NoColor}"
}
function setColorLog(){
	echo -e "$1\c"
}
CODE_VERSION_FILE="./.code-version"

#-------------------------------------------------------
# Calculate Next Version Value.
# The new value is stored in CODE_VERSION_NEXT var
#-------------------------------------------------------
# @params:
# 	version   : current string version value
# 	limit     : indicates the value that will increment next correlative
# 	delimiter : char delimiter of string version
#
#-------------------------------------------------------
# How to use:
#-------------------------------------------------------
# code-version-calc "0.0.0"  10  "." # 0.0.0 --> 0.0.1 
# code-version-calc "0.9.9"  10  "." # 0.9.9 --> 1.0.0
# code-version-calc "0.0.45" 100 "." # "0.0.45" --> "0.0.46" 
# code-version-calc "0.0.99" 100 "." # "0.0.99" --> "0.1.0" 
# code-version-calc "0-0-0"  10  "-" # "0-0-0" --> "0-0-1" 
function code-version-calc(){
	#read params
	current_version=$1
	limit=$2
	delimiter=$3
	# echo " current_version:$current_version"
	# echo " limit:$limit"
	# echo " delimiter:$delimiter"
	#split string current_version into array of values
	IFS_DEF=$IFS
	IFS="$delimiter"
	read -ra values <<<"$current_version"
	IFS=$IFS_DEF

	next=1
	CODE_VERSION_NEXT=""
	# parseNumber $(())
	len=$((${#values[@]}-1))
	for (( i=$len; i>=0 ; i-- )) ; do
		v=$((${values[i]}+next))
		if [ $v -ge $limit ];then
			next=1 v=0
		else
			next=0
		fi
		#echo "i:$i len:$len"
		if [ $i -eq $len ];then
			CODE_VERSION_NEXT="$v"
		else
			CODE_VERSION_NEXT="$v$delimiter$CODE_VERSION_NEXT"
		fi
	done
	echo "$current_version --> $CODE_VERSION_NEXT"

}

function code-version-init(){
	CODE_VERSION_DELIMITER="."
	CODE_VERSION_LIMIT=100
	CODE_VERSION="0.0.0"
	ERRORS_READING_PARAMS=""
	#read options
	for i in "$@"
	do

		{ #TRY
			#echo "CHECKING: $i -> \$1=$1 \$=$2"
			# shift allow alway read $1 as argument and $2 as value
			case $i in
				#------------------------------------
				# CODE_VERSION_DELIMITER
				#------------------------------------
				-d|--delimiter) #Space-Separated 
					CODE_VERSION_DELIMITER="$2"
					#echo "space CODE_VERSION_DELIMITER=$CODE_VERSION_DELIMITER"
					shift # past argument
				;;
				-d=*|--delimiter=*) #Equals-Separated 
					CODE_VERSION_DELIMITER="${i#*=}"
					shift # past argument=value
				;;
				#------------------------------------
				# CODE_VERSION_LIMIT
				#------------------------------------
				-l|--limit) #Space-Separated 
					CODE_VERSION_LIMIT="$2"
					shift # past argument
				;;
				-l=*|--limit=*)
					CODE_VERSION_LIMIT="${i#*=}"
					shift # past argument=value
				;;
				#------------------------------------
				# CODE_VERSION
				#------------------------------------
				-v|--version) #Space-Separated 
					CODE_VERSION="$2"
					read_file=false
					#echo "CODE_VERSION: $CODE_VERSION"
					shift # past argument
				;;
				-v=*|--version=*)
					CODE_VERSION="${i#*=}"
					read_file=false
					shift # past argument=value
				;;
				#------------------------------------
				# UNKNOW COMMAND
				#------------------------------------
				*)
					shift # past argument=value
				;;
			esac
			
		} || { #CATCH
			#ERRORS_READING_PARAMS="$ERRORS_READING_PARAMS\nError reading $i:$?"
			echo "$?"
		}
	done
	echo -e "CODE_VERSION_DELIMITER='$CODE_VERSION_DELIMITER'\nCODE_VERSION_LIMIT='$CODE_VERSION_LIMIT'\nCODE_VERSION='$CODE_VERSION'\n" > "$CODE_VERSION_FILE"
	cat $CODE_VERSION_FILE
}
function code-version(){
	save=false
	read_file=true

	# create file .code-version  if not exist or if --init param was given, with first version config
	if [[ ! -f "$CODE_VERSION_FILE"  ||  "$*" == *--init* ]];then
		#echo "code-version-init $@"
		code-version-init $@
	fi

	source $CODE_VERSION_FILE

	#read options
	for i in "$@"
	do

		{ #TRY
			#echo "cheking $i option $1 $2"
			# shift allow alway read $1 as argument and $2 as value
			case $i in
				#------------------------------------
				# STORE
				#------------------------------------
				-s|--save)
					save=true
					shift # past argument=value
				;;
				
				#------------------------------------
				# UNKNOW COMMAND
				#------------------------------------
				*)
					shift # past argument=value
				;;
			esac
			
		} || { #CATCH
			ERRORS_READING_PARAMS="$ERRORS_READING_PARAMS\nError reading $i:$?"
		}
	done


	#calculate next version
	#echo "code-version-calc $CODE_VERSION $CODE_VERSION_LIMIT $CODE_VERSION_DELIMITER"
	code-version-calc "$CODE_VERSION" "$CODE_VERSION_LIMIT" "$CODE_VERSION_DELIMITER"
	#save new version in file
	if [[ "$save" == true ]];then
		#echo "updating version file"
		echo -e "CODE_VERSION_DELIMITER='$CODE_VERSION_DELIMITER'\nCODE_VERSION_LIMIT='$CODE_VERSION_LIMIT'\nCODE_VERSION='$CODE_VERSION_NEXT'\n" > "$CODE_VERSION_FILE"
	fi
	CODE_VERSION=$CODE_VERSION_NEXT
}
use-agent(){
        if [[ "$*" == *--force* ]];then
                ps -e | grep ssh-agent | awk '{print $1;}' | xargs kill -9 > /dev/null
                eval `ssh-agent -s` 
        fi

        SSH_KEY=$(ls -l ~/.ssh| grep -m1 $1 | awk '{print $9}')

        if [[ -z "$SSH_KEY" ]];then
                echo "ssh key:'$1' not found"
                return 0
        fi
        if [[ "$*" == *--show* ]];then
                cat ~/.ssh/$SSH_KEY
        else
                ssh-add ~/.ssh/$SSH_KEY
        fi
}

load_env_file(){
	#export values from postgres.env
	log "loading env values from file; $1"
	set -o allexport
	source $1
	set +o allexport
}
