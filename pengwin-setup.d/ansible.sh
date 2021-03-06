#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "ANSIBLE" --yesno "Would you like to download and install Ansible?" 8 55); then
  echo "Installing ANSIBLE"
  install_packages ansible
else
  echo "Skipping ANSIBLE"
fi
