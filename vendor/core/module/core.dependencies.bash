#!/usr/bin/env bash

function core_dependencies_1000() {

  _SYSTEM_DEPENDENCIES="zip unzip curl mc bash coreutils jq parallel sshpass vim zcat"

  if (is_mac); then

    if [ $(program_is_installed 'gnu-sed') == 1 ]; then

      ${_BREW} install gnu-sed --with-default-names

    fi

    if [ -f /usr/local/bin/gtac ] && [ ! -f /usr/local/bin/tac​​ ]; then

      ${_LN} -s /usr/local/bin/gtac /usr/local/bin/tac​​

    fi

    local SSH_PASS="sshpass"

    if [ $(program_is_installed ${SSH_PASS}) == 1 ]; then

      local SSH_PASS="https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb"

      install_software ${SSH_PASS}

    fi

  fi

}
