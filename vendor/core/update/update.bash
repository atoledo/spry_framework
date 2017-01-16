#!/usr/bin/env bash

function update_analyze_dependencies() {

  local _UPDATE_DEPENDENCIES_LIST="${@}"
  local _DEPENDENCIES=""
  local _UPDATE_SYSTEM_DEPENDENCIES=""
  filesystem_create_file "${_SPRY_DEPENDENCIES_FILE}"

  if [[ "${_DEBUG}" == "true" ]]; then

    out_warning "Analyzing dependencies [${_UPDATE_DEPENDENCIES_LIST}]" 1

  fi

  for _DEPENDENCIES in ${_UPDATE_DEPENDENCIES_LIST}; do

    if [[ "${_DEBUG}" == "true" ]]; then

      out_info "Processing... ${_DEPENDENCIES}" 1

    fi

    update_process_file ${_DEPENDENCIES}

  done

  update_install_dependencies "${_UPDATE_SYSTEM_DEPENDENCIES[@]}"

}

function update_get_component_path() {

  local _UPDATE_DEPENDENCY="${1}"
  local _UPDATE_PROCESS_PATH=""

  if [ -d "${_VENDOR_FOLDER_PATH}/${_UPDATE_DEPENDENCY}" ]; then

    _UPDATE_PROCESS_PATH="${_VENDOR_FOLDER_PATH}/${_UPDATE_DEPENDENCY}"

  elif [ -d "${_MODULES_FOLDER_PATH}/${_UPDATE_DEPENDENCY}" ]; then

    _UPDATE_PROCESS_PATH="${_MODULES_FOLDER_PATH}/${_UPDATE_DEPENDENCY}"

  elif [ -d "${_TASKS_FOLDER_PATH}" ]; then

    _UPDATE_PROCESS_PATH="${_TASKS_FOLDER_PATH}/${_UPDATE_DEPENDENCY}"

  fi

  echo ${_UPDATE_PROCESS_PATH}

}

function update_process_file() {

  local _UPDATE_DEPENDENCY="${1}"
  local _UPDATE_PROCESS_PATH="$(update_get_component_path ${_UPDATE_DEPENDENCY})"

  local _UPDATE_DEPENDENCY_CODE_VERSION=$(update_get_code_version ${_UPDATE_DEPENDENCY} ${_UPDATE_PROCESS_PATH})
  local _UPDATE_DEPENDENCY_CUR_VERSION=$(update_get_current_version ${_UPDATE_DEPENDENCY})

  if [ -n "${_UPDATE_DEPENDENCY_CODE_VERSION}" ]; then

    if (( ${_UPDATE_DEPENDENCY_CODE_VERSION} > ${_UPDATE_DEPENDENCY_CUR_VERSION} )); then

      if [[ "${_DEBUG}" == "true" ]]; then

        out_warning "${_UPDATE_DEPENDENCY} needs to be updated"

      fi

      update_dependency ${_UPDATE_DEPENDENCY} ${_UPDATE_PROCESS_PATH} ${_UPDATE_DEPENDENCY_CUR_VERSION} ${_UPDATE_DEPENDENCY_CODE_VERSION}

    elif [[ "${_DEBUG}" == "true" ]]; then

      out_success "${_UPDATE_DEPENDENCY} is already updated"

    fi

  elif [[ "${_DEBUG}" == "true" ]]; then

    out_danger "There are no updates from component [${_UPDATE_DEPENDENCY}]"
    echo "Current version: ${_UPDATE_DEPENDENCY_CUR_VERSION}"

  fi

}

function update_get_code_version() {

  local _UPDATE_DEPENDENCY="${1:-}"
  local _UPDATE_PROCESS_PATH="${2:-}"

  local _UPDATE_DEPENDENCY_VERSIONS=""
  local _UPDATE_DEPENDENCY_CODE_VERSION=""

  if [[ -d ${_UPDATE_PROCESS_PATH} ]] && [[ -f "${_UPDATE_PROCESS_PATH}/${_UPDATE_DEPENDENCY}.dependencies.bash" ]]; then

    _UPDATE_DEPENDENCY_VERSIONS=$(egrep -o "^[a-z ]*_dependencies_[0-9]*" "${_UPDATE_PROCESS_PATH}/${_UPDATE_DEPENDENCY}.dependencies.bash")

    if [ -n "${_UPDATE_DEPENDENCY_VERSIONS}" ]; then

      # that function already many function this command are returened many elements
      _UPDATE_DEPENDENCY_CODE_VERSION=$(echo ${_UPDATE_DEPENDENCY_VERSIONS}| rev | cut -d "_" -f1 | rev)

      if [ -n "${_UPDATE_DEPENDENCY_CODE_VERSION}" ]; then

         echo "${_UPDATE_DEPENDENCY_CODE_VERSION}"

      fi

    fi

  fi

}

################################################################################
# @param String _UPDATE_DEPENDENCY - Name of component (Module, Task or Vendor)
#
# Will get the installed version from the control file in filesystem
################################################################################
function update_get_current_version() {

  local _UPDATE_DEPENDENCY="${1:-}"

  local _UPDATE_DEPENDENCY_CUR_VERSION=$(${_CAT} ${_SPRY_DEPENDENCIES_FILE} | ${_GREP} -w ${_UPDATE_DEPENDENCY} | cut -d ":" -f2)

  if [ -n "${_UPDATE_DEPENDENCY_CUR_VERSION}" ]; then

    echo "${_UPDATE_DEPENDENCY_CUR_VERSION}"

  else

    echo "0"

  fi

}

function update_dependency() {

  local _UPDATE_DEPENDENCY="${1:-}"
  local _UPDATE_PROCESS_PATH="${2:-}"
  local _UPDATE_DEPENDENCY_CUR_VERSION="${3:-}"
  local _UPDATE_DEPENDENCY_NEW_VERSION="${4:-}"

  if [[ "${_DEBUG}" == "true" ]]; then

    out_warning "Updating [${_UPDATE_DEPENDENCY}] at [${_UPDATE_PROCESS_PATH}] from [${_UPDATE_DEPENDENCY_CUR_VERSION}] to [${_UPDATE_DEPENDENCY_NEW_VERSION}]"

  fi

  # Get versions from source code
  local _UPDATE_DEPENDENCIES_FUNCTIONS=$(egrep -o "^[a-z ]*_dependencies_[0-9]*" "${_UPDATE_PROCESS_PATH}/${_UPDATE_DEPENDENCY}.dependencies.bash")
  local _UPDATE_DEPENDENCIES_VERSIONS=$(echo "${_UPDATE_DEPENDENCIES_FUNCTIONS}" | rev | cut -d "_" -f1 | rev)
  local _UPDATES=$(echo "${_UPDATE_DEPENDENCIES_VERSIONS}" | awk '$0 > '${_UPDATE_DEPENDENCY_CUR_VERSION}' {print ;}')
  local _UPDATE=""

  for _UPDATE in ${_UPDATES}; do

    update_call_updates "${_UPDATE_DEPENDENCY}" "${_UPDATE}"
    update_write_control_file "${_UPDATE_DEPENDENCY}" "${_UPDATE}"

  done

}


function update_write_control_file() {

  local _UPDATE_DEPENDENCY="${1:-}"
  local _UPDATE_DEPENDENCY_CUR_VERSION="${2:-}"
  local REGEX="${_UPDATE_DEPENDENCY}:[0-9]*"

  # Updating the reference file
  if (${_GREP} -qwo "${REGEX}" ${_SPRY_DEPENDENCIES_FILE}); then

    ${_SED} -i "s/${REGEX}/${_UPDATE_DEPENDENCY}:${_UPDATE_DEPENDENCY_CUR_VERSION}/g" ${_SPRY_DEPENDENCIES_FILE}

  else

    if [[ -f ${_SPRY_DEPENDENCIES_FILE} ]]; then

      echo "${_UPDATE_DEPENDENCY}:${_UPDATE_DEPENDENCY_CUR_VERSION}" >>  ${_SPRY_DEPENDENCIES_FILE}

    fi

  fi

}

function update_call_updates() {

  local _UPDATE_DEPENDENCY="${1:-}"
  local _UPDATE_DEPENDENCY_CUR_VERSION="${2:-}"
  local _DEPENDENCIES="";

  if is_function? "${_UPDATE_DEPENDENCY}_dependencies_${_UPDATE_DEPENDENCY_CUR_VERSION}"; then


    out_info "Executing update function: [ ${_UPDATE_DEPENDENCY}_dependencies_${_UPDATE_DEPENDENCY_CUR_VERSION} ]"
    # Execute the function to execute dependencies on system and populate the _SYSTEM_DEPENDENCIES variable.
    "${_UPDATE_DEPENDENCY}_dependencies_${_UPDATE_DEPENDENCY_CUR_VERSION}"

    for _DEPENDENCIES in ${_SYSTEM_DEPENDENCIES[@]}; do

      if ! in_array? ${_DEPENDENCIES} _UPDATE_SYSTEM_DEPENDENCIES; then

        _UPDATE_SYSTEM_DEPENDENCIES=(${_UPDATE_SYSTEM_DEPENDENCIES[@]} ${_DEPENDENCIES})

      fi

    done

  else

    if [[ "${_DEBUG}" == "true" ]]; then

      out_warning "Function : [ ${_UPDATE_DEPENDENCY}_dependencies_${_UPDATE_DEPENDENCY_CUR_VERSION} ] not exists"

    fi

  fi

}


function update_install_dependencies() {

  local _UPDATE_INSTALL_SYSTEM_DEPENDENCIES="${@}"

  if [[ "${_DEBUG}" == "true" ]]; then

    out_warning "Installing system dependencies: ${_UPDATE_INSTALL_SYSTEM_DEPENDENCIES[@]}" 1

  fi

  if [[ -n ${_UPDATE_INSTALL_SYSTEM_DEPENDENCIES[@]} ]]; then

    update_system_repo
    install_software ${_UPDATE_INSTALL_SYSTEM_DEPENDENCIES[@]}
    out_check_status $? "Dependencies installed successfully." "Error while on installing dependencies."

  fi
}
