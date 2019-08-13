#!/usr/bin/env bash

function yml() {

  if [ -z "${1:-}" ]; then

    raise FileNotFound "File ${1:-} not found!"

  else

    local _YML_FILE=${1}

  fi

  local _YML_PREFIX=${2^^:-}

  local s
  local w
  local fs
  s='[[:space:]]*'
  w='[a-zA-Z0-9_-]*'
  fs="$(echo @|tr @ '\034')"
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "${_YML_FILE}" |
  awk -F"$fs" '{
  indent = length($1)/2;
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
          printf("%s%s%s=(\"%s\")\n", "'"${_YML_PREFIX}"'",toupper(vn), toupper($2), $3);
        }
  }' | sed 's/_=/+=/g'

}

# helper to load yml_parse data file
function yml_parse() {

  local _YML=$(yml "$@")

  while echo -e "${_YML}" | grep -E "[a-zA-Z0-9_]*-[a-zA-Z0-9_]*=" > /dev/null; do

    _YML=$(echo -e "${_YML}" | sed -r "s/^([a-zA-Z0-9_]*)-([a-zA-Z0-9_]*)/\1_\2/g")

  done

  eval "${_YML}"

}
