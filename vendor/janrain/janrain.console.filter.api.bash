#!/usr/bin/env bash

function janrain_console_filter_appowner() {

  local _JANRAIN_CONSOLE_CLIENTS="${1:-}"

  local _JANRAIN_CONSOLE_APPOWNER=$(echo ${_JANRAIN_CONSOLE_CLIENTS} | ${_JQ} '.[] | select(.name=="application owner")')

  echo ${_JANRAIN_CONSOLE_APPOWNER}

}

function janrain_console_filter_appowner_id() {

  local _JANRAIN_CONSOLE_APPOWNER="${1:-}"

  local _JANRAIN_CONSOLE_APPOWNER_ID=$(echo ${_JANRAIN_CONSOLE_APPOWNER} | ${_JQ} '._id')

  echo ${_JANRAIN_CONSOLE_APPOWNER_ID//\"/}

}

function janrain_console_filter_appowner_secret() {

  local _JANRAIN_CONSOLE_APPOWNER="${1:-}"

  local _JANRAIN_CONSOLE_APPOWNER_SECRET=$(echo ${_JANRAIN_CONSOLE_APPOWNER} | ${_JQ} '._secret')

  echo ${_JANRAIN_CONSOLE_APPOWNER_SECRET//\"/}

}
