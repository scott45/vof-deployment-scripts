#!/bin/bash

set -e
set -o pipefail

RUBY_VERSION="${RUBY_VERSION:-2.4.1}"

create_vof_user() {
  if ! id -u vof; then
    sudo useradd -m -s /bin/bash vof
  fi
}

install_system_dependencies() {
  sudo apt-get update -y

  sudo apt-get install -y --no-install-recommends git-core curl zlib1g-dev     \
    build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev wget nodejs     \
    python-software-properties libffi-dev libpq-dev sudo vim less supervisor jq
}

install_ruby(){
  if ! which ruby; then
    install_system_dependencies

    sudo chgrp -R vof  /usr/local
    sudo chmod -R g+rw /usr/local

    curl -k -O -L "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%\.*}/ruby-${RUBY_VERSION}.tar.gz"
    tar zxf ruby-*

    pushd ruby-$RUBY_VERSION
      ./configure
      make && make install
    popd
  fi
}

install_vof_ruby_dependencies() {
  if ! which bundler; then
    curl -O -L -k https://rubygems.org/rubygems/rubygems-2.6.12.tgz

    tar zxf rubygems-2.6.12.tgz
    pushd rubygems-2.6.12
      ruby setup.rb
    popd

    gem install bundler --no-ri --no-rdoc
  fi
}

start_supervisor_service() {
  sudo service supervisor start
}

setup_vof_code() {
  sudo chown -R vof:vof /home/vof
  
  cd /home/vof/app && bundle install
}

main() {
  create_vof_user

  mkdir -p /tmp/workdir
  pushd /tmp/workdir
    install_ruby
    install_vof_ruby_dependencies
  popd
  rm -r /tmp/workdir

  setup_vof_code
  start_supervisor_service
}

main "$@"
