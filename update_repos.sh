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



# declare the variables
DEFAULT_DIRECTORY="/d/GitHub/"
ORG_DIRECTORY="$( pwd )"
SKIP_FILE="skip_file.txt"
COLOR="\e[0;91m"
RESET="\e[0m"
declare -a skip_list
index=0



# check if string passed to script is of 0 length (basically not passed)
if [[ -z ${1} ]]
then
    # default to the hardcoded directory
    ROOT="${DEFAULT_DIRECTORY}"

# check if the string passed is a directory
elif [[ -d ${1} ]]
then
    # set the ROOT to the argument
    ROOT=${1}

# exit if argument was passed but not a valid directory
else
    echo "Fatal! Parameter passed to the script is not a directory"
    echo "exit"
    exit 1
fi



# cd to the directory holding git repos
# remove the errors of cd, as it is handled by if
cd "${ROOT}" 2> /dev/null

# if cd was not successful, exit
if [[ ${?} -ne 0 ]]
then
    echo "Fatal! Error in accessing ${ROOT}"
    echo "exit"
    exit 1
fi



# reassigning to handle relative paths
ROOT="$( pwd )"



# function to read lines of the SKIP_FILE into array skip_list
# --------------------------------------------------------------------------------
load_skip_file()
{
    # start reading the file only if it exists
    if [[ -f "${ORG_DIRECTORY}/${SKIP_FILE}" ]]
    then
        # IFS= (or IFS='') prevents leading/trailing whitespace from being trimmed
        # -r prevents backslash escapes from being interpreted
        # || [[ -n $line ]] prevents the last line from being ignored if it doesn't end with a \n
        # More details here - https://stackoverflow.com/a/10929511/16018083
        while IFS= read -r line || [[ -n "${line}" ]];
        do
            # process the line only if it represents a directory
            if [[ -d ${line} ]]
            then
                # store the absolute path of the directory location read in the array at ${index}
                skip_list["${index}"]="$(realpath "${line}")"
            fi

            # increment the index
            index=$(("${index}" + 1))
        done < "${ORG_DIRECTORY}/${SKIP_FILE}"
    fi
}
# --------------------------------------------------------------------------------


# function to check if the argument is in the array skip_list
# --------------------------------------------------------------------------------
check_if_to_be_skipped()
{
    found="false"

    # loop for all elements in the array
    for i in "${skip_list[@]}";
    do
        # check if parameter passed is in the array
        if [ "${1}" = "${i}" ];
        then
            found="true"
        fi
    done

    echo ${found}
}
# --------------------------------------------------------------------------------



# function to navigate into directories and subdirectories
# --------------------------------------------------------------------------------
navigator()
{
    # print this for debug only
    # printf "\n[INFO] Working on ${1}\n"

    # if the repository is to be skipped from updating
    if [[ "$(check_if_to_be_skipped ${1})" = "true" ]]
    then
        # printf "\n[INFO] Skipping ${1}\n"
        return 0
    fi

    # check if current directory is a git repo
    is_repo=$(is_git_repo)

    # if a git repo, update it
    if [[ "${is_repo}" = "true" ]]
    then
        update_repo "${1}"
        # terminate the function as repo inside repo is currently not supported
        return 0
    else
        # if not a git repo, loop through all files and folders inside working directory
        for ITEM in *;
        do
            ITEM_PATH="${1}/${ITEM}"

            # if a directory is found, go inside it and repeat the process
            if [[ -d "${ITEM_PATH}" ]]
            then
                cd "${ITEM_PATH}"
                navigator "${ITEM_PATH}"

                # come out once every recursive call is made
                cd ../
            fi
        done
    fi
}
# --------------------------------------------------------------------------------



# function to check if working directory is a git repo
# --------------------------------------------------------------------------------
is_git_repo()
{
    is_repo="$( git rev-parse --is-inside-work-tree 2>/dev/null )"

    if [[ "${is_repo}" = "true" ]]
    then
        echo "true"
    else
        echo "false"
    fi
}
# --------------------------------------------------------------------------------



# function to pull the remote repo
# --------------------------------------------------------------------------------
update_repo()
{
    printf "\n[${COLOR}UPDATING${RESET}] ${1}\n\n"
     # pull is fast forward so that no unusual changes are done in local repo
    printf "$( git pull --ff-only )"

    printf "\n\n"
}
# --------------------------------------------------------------------------------



# load the SKIP_FILE
load_skip_file

# update the repos
navigator "${ROOT}"; exit
