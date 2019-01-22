#!/usr/bin/env bash

function janrain_console_get_apps() {

  local _JANRAIN_CONSOLE_REGION="${1:-}"
  local _JANRAIN_CONSOLE_SESSION="${2:-}"

  local _RESPONSE=$(janrain_console_get ${_JANRAIN_CONSOLE_REGION} "/console/applications" "${_JANRAIN_CONSOLE_SESSION}")

  echo ${_RESPONSE}

}

function janrain_console_get_uiapps() {

  local _JANRAIN_CONSOLE_REGION="${1:-}"
  local _JANRAIN_CONSOLE_SESSION="${2:-}"
  local _JANRAIN_CONSOLE_APP="${3:-}"

  local _RESPONSE=$(janrain_console_get ${_JANRAIN_CONSOLE_REGION} "/console/applications/${_JANRAIN_CONSOLE_APP}/uiapps" "${_JANRAIN_CONSOLE_SESSION}")

  echo ${_RESPONSE}

}

function janrain_console_get_clients() {

  local _JANRAIN_CONSOLE_REGION="${1:-}"
  local _JANRAIN_CONSOLE_SESSION="${2:-}"
  local _JANRAIN_CONSOLE_APP="${3:-}"

  local _RESPONSE=$(janrain_console_get ${_JANRAIN_CONSOLE_REGION} "/console/applications/${_JANRAIN_CONSOLE_APP}/clients" "${_JANRAIN_CONSOLE_SESSION}")

  echo ${_RESPONSE}

}
