# update_repos.sh

Purpose of this script is to run a `git pull --ff-only` on the active branch for all the repositories in the directory hardcoded in the script or supplied as a parameter to the script



## Features

+ Run `git pull --ff-only` quickly on all the repositories contained in a directory

+ If some repositories need to be excluded, simply enlist them in the file `skip_file.txt`, and place this file in the project directory



## Dependencies

+ git or git bash installed

+ configured upstream in the repository



## How to use

+ Clone this repository on your local machine or extract the downloaded the zip archive

+ Let's say you have some git repos in the folder `/home/user/repos/` which you want to sync with the remote repo

+ Run the command in shell or git bash
   ```shell
   ./update_repos.sh /home/user/repos
   ```

+ If you would like to run the script without any parameter, edit the script to change the variable `DEFAULT_DIRECTORY` at the beginning of the script, and make it point to the local repo in your disk

+ Once the change is done, simply run the command
   ```shell
   ./update_repos.sh
   ```



## To note

+ In case of errors during the process, this script simply continue until it ends

+ Doesn't handle the merge conflicts or sync errors, but displays the message, so that necessary step can be taken
