#!/usr/bin/env bash

function acquia_files_download() {

  if [ -z ${1:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_download] Please provide a valid subscription"

  else

    local _ACQUIA_FILES_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_download] Please provide a valid environment"

  else

    local _ACQUIA_FILES_ENVIRONMENT=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_download] Please provide a valid subsite"

  else

    local _ACQUIA_FILES_SUBSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_download] Please provide a valid folder"

  else

    local _ACQUIA_FILES_LOCAL_PATH=${4}

  fi


  local _ACQUIA_FILES_FORCE_DOWNLOAD=""
  if [ ! -z ${5:-} ]; then

    local _ACQUIA_FILES_FORCE_DOWNLOAD=${5:-}

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == 1 ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == "true" ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == "y" ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

  fi

  if [ -L ${_ACQUIA_FILES_LOCAL_PATH} ]; then

    out_warning "Removing old link ${_ACQUIA_FILES_LOCAL_PATH}"
    ${_UNLINK} ${_ACQUIA_FILES_LOCAL_PATH}

  fi

  filesystem_create_folder_777 ${_ACQUIA_FILES_LOCAL_PATH}

  if [ ! -d ${_ACQUIA_FILES_LOCAL_PATH} ]; then

    raise FolderNotFound "Folder not found: ${_ACQUIA_FILES_LOCAL_PATH}"

  fi

  local _REMOTE_PATH="@${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}:/mnt/gfs/${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}/sites/${_ACQUIA_FILES_SUBSITE}/files/"

  out_info "Downloading files from @${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}" 1
  drush_rsync_site ${_REMOTE_PATH} ${_ACQUIA_FILES_LOCAL_PATH} ${_ACQUIA_FILES_FORCE_DOWNLOAD}
  out_check_status $? "Download to directory [ ${_ACQUIA_FILES_LOCAL_PATH} ] successfully" "Failed download file: [ @${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}:${_REMOTE_PATH} ]"
  ${_CHMOD} -R 777 "${_ACQUIA_FILES_LOCAL_PATH}"

}


function acquia_files_upload() {

  if [ -z ${1:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_upload] Please provide a valid subscription"

  else

    local _ACQUIA_FILES_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_upload] Please provide a valid environment"

  else

    local _ACQUIA_FILES_ENVIRONMENT=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_upload] Please provide a valid subsite"

  else

    local _ACQUIA_FILES_SUBSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    raise RequiredFolderNotFound "[acquia_files_upload] Please provide a valid folder"

  else

    local _ACQUIA_FILES_LOCAL_PATH=${4}

  fi


  local _ACQUIA_FILES_FORCE_DOWNLOAD=""
  if [ ! -z ${5:-} ]; then

    local _ACQUIA_FILES_FORCE_DOWNLOAD=${5:-}

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == 1 ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == "true" ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_ACQUIA_FILES_FORCE_DOWNLOAD}" == "y" ]; then

      _ACQUIA_FILES_FORCE_DOWNLOAD="-y"

    fi

  fi

  if [ ! -d ${_ACQUIA_FILES_LOCAL_PATH} ]; then

    raise FolderNotFound "Folder not found: ${_ACQUIA_FILES_LOCAL_PATH}"

  fi
  local _REMOTE_PATH="@${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}:/mnt/gfs/${_ACQUIA_FILES_SUBSCRIPTION}.${_ACQUIA_FILES_ENVIRONMENT}/sites/${_ACQUIA_FILES_SUBSITE}/files/"

  out_info "Uploading files to @${_ACQUIA_FILES_SUBSITE}.${_ACQUIA_FILES_ENVIRONMENT}"
  drush_rsync_site ${_ACQUIA_FILES_LOCAL_PATH} ${_REMOTE_PATH} ${_ACQUIA_FILES_FORCE_DOWNLOAD}
  out_check_status $? "Upload to directory [ ${_ACQUIA_FILES_LOCAL_PATH} ] successfully" "Failed upload file: [ ${_REMOTE_PATH} ]"

}
