#!/usr/bin/env bash

function janrain_entity() {

  local _JANRAIN_CLIENT_ID=${1}
  local _JANRAIN_CLIENT_SECRET=${2}
  local _JANRAIN_CONTENT_TYPE=${3}
  local _JANRAIN_POST_DATA=${4}
  local _JANRAIN_ENDPOINT=${5}

  if [ -z ${_JANRAIN_CLIENT_ID:-} ] || [ -z ${_JANRAIN_CLIENT_SECRET:-} ]; then

    raise MissingRequiredConfig "[janrain_entity] Please configure variables _JANRAIN_CLIENT_ID and _JANRAIN_CLIENT_SECRET in configuration file [config/janrain_config.bash]"

  fi

  if [ -z ${_JANRAIN_DOMAIN_URL:-} ]; then

    raise MissingRequiredConfig "[janrain_entity] Please configure variable _JANRAIN_DOMAIN_URL in configuration file [config/janrain_config.bash]"

  fi

  ${_CURL} -g -s -X POST -u ${_JANRAIN_CLIENT_ID}:${_JANRAIN_CLIENT_SECRET} -H "Content-Type: ${_JANRAIN_CONTENT_TYPE}" "${_JANRAIN_DOMAIN_URL}/${_JANRAIN_ENDPOINT}?${_JANRAIN_POST_DATA}"
}


function janrain_console_get() {

  local _JANRAIN_CONSOLE_REGION="${1:-}"
  local _JANRAIN_CONSOLE_URI="${2:-}"
  local _JANRAIN_CONSOLE_SESSION="${3:-}"

  local _JANRAIN_CONSOLE_SESSION_SUM=$(echo ${_JANRAIN_CONSOLE_SESSION} | md5sum | sed "s/[ -]//g")

  local _CACHE_FILE="${_SF_TEMPORARY_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_JANRAIN_CONSOLE_SESSION_SUM}/${_JANRAIN_CONSOLE_REGION}/${_JANRAIN_CONSOLE_URI//\//_}.cache"

  if [ -s "${_CACHE_FILE}" ]; then

    ${_CAT} ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _JANRAIN_CONSOLE_REGIONAL_DOMAIN=$(echo $_JANRAIN_CAPI_DOMAIN | sed -e "s/us/${_REGION}/g")

  local _RESPONSE=$(rest_get "${_JANRAIN_CONSOLE_REGIONAL_DOMAIN}" "${_JANRAIN_CONSOLE_URI}" "" "" "cookie:CONSOLE_CCP_SESSION=${_JANRAIN_CONSOLE_SESSION}")

  if (! ${_JQ} -e . >/dev/null 2>&1 <<<"${_RESPONSE}"); then

    return 1;

  fi

  echo "${_RESPONSE}" | tee ${_CACHE_FILE}

}
