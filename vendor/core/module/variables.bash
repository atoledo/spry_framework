#!/usr/bin/env bash

readonly _PWD=$(pwd)
readonly _PARENT_DIR=$(dirname ${_PWD})
readonly _SCRIPT_NAME=$(basename "$0")
readonly _SPRY_DEPENDENCIES_FILE="${HOME}/.spry/config/${_SPRY_FRAMEWORK_PROJECT_NAME}_dependencies.conf"
readonly _VENDOR_FOLDER_PATH="${_SPRY_SCRIPT_HOME}/vendor"
readonly _CORE_FOLDER_PATH="${_SPRY_SCRIPT_HOME}/vendor/core"
readonly _MODULES_FOLDER_PATH="${_SPRY_SCRIPT_HOME}/modules"
readonly _CONFIG_FOLDER_PATH="${_SPRY_SCRIPT_HOME}/config"
readonly _TASKS_FOLDER_PATH="${_SPRY_SCRIPT_HOME}/tasks"
readonly _SF_TMP_DIR="/tmp/spry/${_SPRY_FRAMEWORK_PROJECT_NAME}"
readonly _SF_TEMPORARY_CACHE_BASE_FOLDER="${_SF_TMP_DIR}/temp_cache"
readonly _SF_STATIC_CACHE_BASE_FOLDER="${_SF_TMP_DIR}/static_cache"
readonly _DEVOPS_LOG_FOLDER="/var/log/${_SCRIPT_NAME}/${_TASK_NAME}"
readonly _DEVOPS_LOG_PATH="${_DEVOPS_LOG_FOLDER}/${_TASK_NAME}_$(date +\%F\-\-\%H\-\%M\-\%S).log"
readonly _USER="${SUDO_USER:-"$USER"}"
readonly _NPM=$(which npm)
readonly _SUDO=$(which sudo)
readonly _GRUNT=$(which grunt)
readonly _BUNDLE=$(which bundle)
readonly _GIT=$(which git)
readonly _DRUSH=$(which drush)
readonly _DRUSH8=$(which drush8)
readonly _DOCKER=$(which docker)
readonly _DOCKER_COMPOSE=$(which docker-compose)
readonly _RSYNC=$(which rsync)
readonly _SED=$(which sed)
readonly _CP=$(which cp)
readonly _CD="cd"
readonly _CAT=$(which cat)
readonly _RM=$(which rm)
readonly _SPLIT=$(which split)
readonly _TAR=$(which tar)
readonly _LN=$(which ln)
readonly _JQ=$(which jq)
readonly _FIND=$(which find)
readonly _LS=$(which ls)
readonly _ZCAT=$(which zcat)
readonly _PATCH=$(which patch)
readonly _CURL=$(which curl)
readonly _SORT=$(which sort)
readonly _NOTIFY=$(which notify-send)
readonly _MKDIR=$(which mkdir)
readonly _TOUCH=$(which touch)
readonly _CHMOD="$(which chmod)"
readonly _RMF="$(which rm) -rf"
readonly _GREP="$(which grep)"
readonly _UNLINK="$(which unlink)"
readonly _CHOWN="$(which chown) -R"
readonly _MYSQL="$(which mysql)"
readonly _MYSQLDUMP="$(which mysqldump)"
readonly _MYSQLCHECK="$(which mysqlcheck)"
readonly _MYSQLSHOW="$(which mysqlshow)"
readonly _A2ENSITE="$(which a2ensite)"
readonly _SERVICE="$(which service)"
readonly _TAIL="$(which tail)"
readonly _MV="$(which mv)"
readonly _BREW="$(which brew)"
readonly _NOTIFY_SUCCESS="1"
readonly _NOTIFY_WARNING="2"
readonly _NOTIFY_DANGER="3"
readonly _NOTIFY_ANGRY="4"

declare -A _CORE_REGISTRY
declare -A _LOG_PARMETERS
