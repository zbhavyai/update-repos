#!/bin/sh
# Author: zbhavyai
#
# Purpose of this script is to run a git pull with fast fastword only mode
# on the active branch for all the repositories inside the folder supplied
#
# Note: Doesn't support git submodules
#
# Usage:
# Method 1: pass the folder containing all the git repo as a parameter to
# this script, and then run the script like below
# ./update_repos.sh "/d/somefolders/.../repo_folder"
#
# Method 2: edit this script to change the DEFAULT_DIRECTORY to the folder
# containing all your git repos, and then run the script like below
# ./update_repos.sh


DEFAULT_DIRECTORY="/d/GitHub/university-calgary"
COLOR="\e[0;91m"
RESET="\e[0m"


# check if the directory was passed as a parameter to the script
# else default to the hardcoded value of directory
if [[ -z $1 ]]							# check if string passed to script is of 0 length (basically not passed)
then
	ROOT="${DEFAULT_DIRECTORY}"
elif [[ -d $1 ]]						# check if the string passed is a directory
then
	ROOT=$1
else
	echo "Fatal! Parameter passed to the script is not a directory"
	echo "exit"
	exit 1
fi


# cd to the directory holding git repos
# if fail, exit the script
cd "${ROOT}" 2> /dev/null								# remove the errors of cd, as it is handled by if
if [[ $? -ne 0 ]]										# if cd was not successful, exit
then
	echo "Fatal! Error in accessing ${ROOT}"
	echo "exit"
	exit 1
fi


ROOT="$( pwd )"											# reassigning to handle relative paths


# function to navigate into directories and subdirectories
navigator()
{
	# printf "\n[INFO] Working on ${1}\n"				# print this for debug only

	is_repo=$(is_git_repo)								# check if current directory is a git repo

	if [[ "${is_repo}" = "true" ]]						# if a git repo, update it
	then
		update_repo "$1"
		return 0										# terminate the function as repo inside repo is currently not supported
	else
		for ITEM in *;									# if not a git repo, loop through all files and folders inside working directory
		do
			ITEM_PATH="$1/${ITEM}"

			if [[ -d "${ITEM_PATH}" ]]					# if a directory is found, go inside it and repeat the process
			then
				cd "${ITEM_PATH}"
				navigator "${ITEM_PATH}"
				cd ../									# come out once every recursive call is made
			fi
		done
	fi
}


# function to check if working directory is a git repo
is_git_repo()
{
	is_repo="$( git rev-parse --is-inside-work-tree 2>/dev/null )"

	if [[ "$is_repo" = "true" ]]
	then
		echo "true"
	else
		echo "false"
	fi
}


# function to pull the remote repo
update_repo()
{
	printf "\n[${COLOR}UPDATING${RESET}] ${1}\n\n"
	printf "$( git pull --ff-only )"					# pull is fast forward so that no unusual changes are done in local repo

	printf "\n\n"
}


navigator "$ROOT"; exit									# call to the main function of the script
