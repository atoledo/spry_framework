#!/usr/bin/env bash

function bootstrap_autoload() {

  for _FILE in $@; do

    if [ -n ${_FILE} ] && [ -f ${_FILE} ]; then # -n tests to see if the argument is non empty

      source ${_FILE}

    fi

  done

}

function bootstrap_init() {

  filesystem_delete_folder ${_SF_STATIC_CACHE_BASE_FOLDER}
  bootstrap_invoke_all "init"

}

function bootstrap_exit() {

  filesystem_delete_folder ${_SF_STATIC_CACHE_BASE_FOLDER}
  bootstrap_invoke_all "exit"

  local _DURATION=$SECONDS
  out_success "Execution time: $((${_DURATION} / 60))m $((${_DURATION} % 60))s" 1

}

function bootstrap_core() {

  local _LOAD_FILES=$(find "${_SPRY_SCRIPT_HOME}/vendor/core" -type f -iname "*.sh" -o -iname "*.bash");

  [ "${_DEBUG}" == "true" ] && echo "[bootstrap_core] Autoloading core files"
  bootstrap_autoload ${_LOAD_FILES}

}

function bootstrap_load_tasks() {

  local _LOAD_FILES=$(find "${_TASKS_FOLDER_PATH}" -type f -iname "${_TASK_NAME}.sh");
  if [[ -z "${_LOAD_FILES}" ]]; then

    raise FolderNotKnown "[bootstrap_load_tasks] Folder '${_TASK_NAME}' is unknown"

  fi

  local _LOAD_TASK_PARENT_DIR="$(dirname  ${_LOAD_FILES})"
  export _TASK_PARENT_NAME="$(basename ${_LOAD_TASK_PARENT_DIR})"
  local _LOAD_TASK_DIR="${_TASKS_FOLDER_PATH}/${_TASK_PARENT_NAME}"
  if [ -d ${_LOAD_TASK_DIR} ]; then

    # Load also any bash files if available inside the task folder
    _LOAD_FILES="${_LOAD_FILES} $(find "${_LOAD_TASK_DIR}" -type f -iname "*.bash")"

  fi

  [ "${_DEBUG}" == "true" ] && echo "[bootstrap_load_tasks] Autoloading task files"
  bootstrap_autoload ${_LOAD_FILES[@]}

}

function bootstrap_load_modules() {

  while [[ ! -z "${_MODULE_DEPENDENCIES:-}" && -n "${_MODULE_DEPENDENCIES[@]}" && "${#_MODULE_DEPENDENCIES[@]}" -ge 1 && -n "${#_LOADED_MODULE_DEPENDENCIES[@]}" ]]; do

    local _FOLDERS=("")
    for _FOLDER in ${_MODULE_DEPENDENCIES[@]}; do

      local _ERRORS_FOUND="false"

      if [ -d "${_VENDOR_FOLDER_PATH}/${_FOLDER}" ]; then

        _FOLDERS=(${_FOLDERS[@]} "${_VENDOR_FOLDER_PATH}/${_FOLDER}")

      else

        if [ -d "${_MODULES_FOLDER_PATH}/${_FOLDER}" ]; then

          _FOLDERS=(${_FOLDERS[@]} "${_MODULES_FOLDER_PATH}/${_FOLDER}")

        else

          _ERRORS_FOUND=true

        fi

        if [ ${_ERRORS_FOUND} == true ];then

          raise FolderNotKnown "[bootstrap_load_modules] Folder '${_MODULES_FOLDER_PATH}/${_FOLDER}' is unknown"

        fi

      fi

    done

    local _LOAD_FILES=$(find ${_FOLDERS[@]} -not \( -path "${_CORE_FOLDER_PATH}" -prune \) -type f -iname "*.bash");
    local _LOADED_MODULE_DEPENDENCIES_BATCH=(${_MODULE_DEPENDENCIES[@]})

    [ "${_DEBUG}" == "true" ] && echo "[bootstrap_load_modules] Autoloading modules files"
    bootstrap_autoload ${_LOAD_FILES}
    if [ ! -z ${_LOADED_MODULE_DEPENDENCIES_BATCH:-} ]; then

      bootstrap_update_loaded_files ${_LOADED_MODULE_DEPENDENCIES_BATCH[@]}

    fi

  done

  bootstrap_load_configs

}

function bootstrap_load_configs() {
  # Load config variables from dependencies
  for _MODULE in ${_LOADED_MODULE_DEPENDENCIES[@]}; do

    local _CONFIG_PATH="${_CONFIG_FOLDER_PATH}/${_MODULE}_config.bash"

    [ "${_DEBUG}" == "true" ] && echo "[bootstrap_load_modules] Autoloading modules config files"
    bootstrap_autoload ${_CONFIG_PATH}

  done

  # Load config variables from running task
  local _TASK_CONFIG_PATH="${_CONFIG_FOLDER_PATH}/${_TASK_PARENT_NAME}_config.bash"

  [ "${_DEBUG}" == "true" ] && echo "[bootstrap_load_modules] Autoloading task config files"
  bootstrap_autoload ${_TASK_CONFIG_PATH}

}

function bootstrap_update_loaded_files() {

  for _MODULE in ${@}; do

    if ! in_array? ${_MODULE} _LOADED_MODULE_DEPENDENCIES; then

      _LOADED_MODULE_DEPENDENCIES=(${_LOADED_MODULE_DEPENDENCIES[@]} $_MODULE)

      _TEMP_DEPENDENCY_LIST=(${_MODULE_DEPENDENCIES[@]/$_MODULE})

      if [ ! -z ${_TEMP_DEPENDENCY_LIST:-} ]; then

        _MODULE_DEPENDENCIES=(${_TEMP_DEPENDENCY_LIST[@]})

      else

        _MODULE_DEPENDENCIES=()

      fi

    fi

  done

}

function bootstrap_update() {

  local _SYSTEM_DEPENDENCIES=""

  update_analyze_dependencies ${_TASK_NAME} "${_LOADED_MODULE_DEPENDENCIES[@]}"

}

function bootstrap_load_components() {

  local _BOOSTRAP_LOAD_COMPONENTS=${@}
  local _COMPONENT=""

  for _COMPONENT in ${_BOOSTRAP_LOAD_COMPONENTS[@]}; do

    local _COMPONENT_PATH="$(update_get_component_path ${_COMPONENT})"
    local _COMPONENT_FROM_SRC=$(find ${_COMPONENT_PATH} -regex ".*.dependencies.bash")

    [ "${_DEBUG}" == "true" ] && echo "[bootstrap_load_components] Autoloading dependencies files"
    bootstrap_autoload ${_COMPONENT_FROM_SRC}

  done

}

function bootstrap_installer_dependencies() {

  local _SYSTEM_DEPENDENCIES=""
  local _MODULE_DEPENDENCIES=$(egrep -ir "_dependencies_[0-9]{1,4}" ${_SPRY_SCRIPT_HOME}/tasks/ -o ${_SPRY_SCRIPT_HOME}/modules/ -o ${_SPRY_SCRIPT_HOME}/vendor/ | grep -o "[a-zA-Z_]*.dependencies.bash" |sed -e "s#.dependencies.bash##g" | sort -u | sed -e "s#\n# ##g")
  bootstrap_load_components ${_MODULE_DEPENDENCIES[@]}
  update_analyze_dependencies ${_MODULE_DEPENDENCIES[@]}

}

function bootstrap_copy_configs_from_dist() {

  local _CONFIG_DIST_FILES=${@}

  for _CONFIG_DIST_FILE in ${_CONFIG_DIST_FILES}; do

    local _CONFIG_FILE=$(echo "${_CONFIG_DIST_FILE}" | ${_SED} 's/.*\///' | ${_SED} s/.dist//g)
    local _CONFIG_EXIST=$(find "${_SPRY_SCRIPT_HOME}" -type f -iname "${_CONFIG_FILE}");

    if [ -z ${_CONFIG_EXIST} ]; then

      _CONFIG_FILE_PATH="${_CONFIG_FOLDER_PATH}/${_CONFIG_FILE}"
      out_warning "Creating ${_CONFIG_FILE_PATH} from ${_CONFIG_DIST_FILE}."
      ${_CP} ${_CONFIG_DIST_FILE} ${_CONFIG_FILE_PATH}

    fi

  done

}

function bootstrap_create_configuration_files() {

  local _TASKS_CONFIG_DIST=$(find ${_TASKS_FOLDER_PATH} -type f -iname "*_config.bash.dist");
  local _MODULES_CONFIG_DIST=$(find ${_MODULES_FOLDER_PATH} -type f -iname "*_config.bash.dist");
  local _CORE_CONFIG_DIST=$(find ${_VENDOR_FOLDER_PATH} -type f -iname "*_config.bash.dist");

  # tasks
  bootstrap_copy_configs_from_dist ${_TASKS_CONFIG_DIST}

  # modules
  bootstrap_copy_configs_from_dist ${_MODULES_CONFIG_DIST}

  # vendor
  bootstrap_copy_configs_from_dist ${_CORE_CONFIG_DIST}

}

function bootstrap_run() {

  # Shift task name parameter
  shift

  bootstrap_init

  #Check missing require configurations
  if is_function? "${_TASK_PARENT_NAME}_configurations"; then

    "${_TASK_PARENT_NAME}_configurations"

  fi

  # Validate usage if available. Otherwise, just execute
  if ! is_function? "${_TASK_NAME}_usage" || (is_function? "${_TASK_NAME}_usage" && "${_TASK_NAME}_usage" "$@"); then

    if is_function? "${_TASK_NAME}_run"; then

      "${_TASK_NAME}_run" "$@"

    else

      raise RunFunctionNotFound "[bootstrap_run] Task '${_TASK_NAME}' did not implement the run function"

    fi

  else

    raise InvalidTaskUsage "[bootstrap_run] Task usage is invalid for task '${_TASK_NAME}'"

  fi

}

function bootstrap_invoke_all() {

  local _BOOTSTRAP_HOOK="${1:-}"
  shift 1
  local _BOOTSTRAP_HOOK_PARAMS="${@}"

  for _MODULE in "${_LOADED_MODULE_DEPENDENCIES[@]}"; do

    if (is_function? "${_MODULE}_${_BOOTSTRAP_HOOK}" ); then

      "${_MODULE}_${_BOOTSTRAP_HOOK}" ${_BOOTSTRAP_HOOK_PARAMS}

    fi

  done

}
