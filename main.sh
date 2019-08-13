#!/usr/bin/env bash

#TODO All sudo actions must be performed during script install/setup

## BASH GLOBAL CONFIGURATION
[ -z "${_DEBUG}" ] && _DEBUG=false

export _SPRY_SCRIPT_HOME=$(dirname "$0")
set -o errexit # make your script exit when a command fails
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
set -o nounset # exit when your script tries to use undeclared variables

#TODO Implement debugging
if [[ "${_DEBUG}" == "strict" ]]; then # check if the debug flag is on

  set -x # prints shell input lines as they are read

fi

# Setup this variable in jenkins providing the path to the scripts. It may be
# a workspace of another job
if [ -z "${_SPRY_SCRIPT_HOME:-}" ]; then

  echo -e "\033[1;91m[ ✘ ] The program was aborted due to an error:\n"
  echo -e "\tEXCEPTION NoTaskSpecified: _SPRY_SCRIPT_HOME variable not set and default path is not valid\033[0m"
  exit 100;

fi

if [ ${#} -ge 1 ]; then

  [ -f "${_SPRY_SCRIPT_HOME}/.env" ] && source "${_SPRY_SCRIPT_HOME}/.env"
  source "${_SPRY_SCRIPT_HOME}/bootstrap.bash"
  readonly _TASK_NAME=${1}
  export _TASK_PARENT_NAME=""
  bootstrap_core
  bootstrap_load_tasks
  bootstrap_load_modules
  bootstrap_update
  bootstrap_run "$@"
  bootstrap_exit

else

  echo -e "\033[1;91m[ ✘ ] The program was aborted due to an error:\n"
  echo -e "\tEXCEPTION NoTaskSpecified: No task was specified to be executed\033[0m"
  exit 100

fi
