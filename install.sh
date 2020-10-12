#!/bin/sh

function install_parallel() {
  CURDIR="$(pwd)"
  [ -d tmp ] || mkdir tmp && cd tmp
  [ -d bin ] || mkdir bin

  wget 'http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2'
  tar -xf parallel-latest.tar.bz2

  cd "$(als  parallel-latest.tar.bz2 | grep --max-count=1 -o 'parallel-[0-9]*/')"

  ./configure
  make

  cp src/parcat src/parsort src/parallel src/niceload src/parset src/sem src/env_parallel.zsh "${CURDIR}/bin"
  cd - rm --recursive parallel-latest.tar.bz2; cd "${CURDIR}"
}

function install_sqlite3() {
  sudo apt update && sudo apt upgrade && \
  sudo apt install --yes libsqlite3-dev libreadline-dev libeditline-dev tcl

  CURDIR="$(pwd)"
  [ -d tmp ] || mkdir tmp
  [ -d bin ] || mkdir bin
  [ -d lib ] || mkdir lib
  cd tmp

  wget 'https://www.sqlite.org/src/tarball/sqlite.tar.gz'
  tar -xf sqlite.tar.gz && cd sqlite

  ./configure --enable-all --enable-tempstore --enable-threadsafe --enable-readline
  make
  #make test
  cp sqlite3 "${CURDIR}/bin"

  gcc -shared -fPIC -Wall -I. ./ext/misc/spellfix.c -o spellfix.so
  cp spellfix.so "${CURDIR}/lib"

  cd "${CURDIR}"
  rm --recursive sqlite.tar.gz sqlite
  rmdir tmp
}


# Install  dependencies

sudo apt update && sudo apt install zsh pv

install_parallel
install_sqlite

