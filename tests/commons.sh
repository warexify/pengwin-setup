#!/bin/bash

export TEST_USER=test_user

function oneTimeSetUp() {
  # shellcheck disable=SC2155
  export PATH="$(pwd)/stubs:${PATH}"
  export HOME="/home/${TEST_USER}"

  sudo /usr/sbin/adduser --quiet --disabled-password --gecos '' ${TEST_USER}
  sudo /usr/sbin/usermod -aG adm,cdrom,sudo,dip,plugdev ${TEST_USER}
  echo "%${TEST_USER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/passwordless-sudo
  sudo chmod +x run-pengwin-setup.sh
  sudo chmod +x stubs/*

  sudo chmod 777 -R "${SHUNIT_TMPDIR}"

  export SHUNIT_TMPDIR
}

function oneTimeTearDown() {
  if id "test_user" &>/dev/null; then
    sudo /usr/sbin/deluser ${TEST_USER} &>/dev/null
  fi

}

function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list $1 2>/dev/null | grep -c "\[install") # so it matches english "install" and also german "installiert"

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

function run_test() {
  echo "********************************************************************"
  echo "$@"
  "$@"
}

function run_pengwinsetup() {
  sudo su - -c "$(pwd)/run-pengwin-setup.sh $*" ${TEST_USER}
}

function run_command_as_testuser() {
  sudo su - -c "$*" ${TEST_USER}
}
