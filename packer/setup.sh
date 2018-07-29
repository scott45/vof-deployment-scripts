#!/bin/bash

set -e
set -o pipefail

create_vof_user() {
  if ! id -u vof; then
    sudo useradd -m -s /bin/bash vof
  fi
}

setup_vof_code() {
  sudo chown -R vof:vof /home/vof
  cd /home/vof/app && bundle install
}

start_supervisor_service() {
  sudo service supervisor start
}

install_filebeat() {
  sudo systemctl stop apt-daily.service
  sudo systemctl stop apt-daily.timer
  sudo systemctl stop apt-daily-upgrade.service
  sudo systemctl stop apt-daily-upgrade.timer
  curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.2.4-amd64.deb
  sudo dpkg -i filebeat-6.2.4-amd64.deb
  sudo apt-get update
}

main() {
  create_vof_user

  setup_vof_code
  start_supervisor_service

  install_filebeat
}

main "$@"
