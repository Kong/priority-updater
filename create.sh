#!/usr/bin/env bash

if [ "$1" == "--help" ]; then
  echo "Utility to create Kong plugins with alternate priority."
  echo
  echo "It will create a NEW plugin identical to the original one,"
  echo "but with the new priority."
  echo
  echo "Usage:"
  echo "    ${BASH_SOURCE[0]} \"PLUGIN_NAME\" \"NEW_PRIORITY\""
  echo
  echo "    PLUGIN_NAME  : name of existing plugin to re-prioritize"
  echo "    NEW_PRIORITY : the priority the new plugin should have"
  echo
  echo "The new plugin will have the old name with priority attached."
  echo "This new name is mandatory and cannot be changed."
  echo
  echo "Example:"
  echo "    ${BASH_SOURCE[0]} \"request-termination\" \"15\""
  echo
  echo "Will create:"
  echo "    kong-plugin-request-termination_15-0.1-1.rock"
  echo
  echo "It can be installed using:"
  echo "    luarocks install kong-plugin-request-termination_15-0.1-1.rock"
  echo

  exit 0
fi

PLUGINNAME="$1"
PRIORITY="$2"
KONG_VERSION="${3:-kong:2.1.4}"

if [ "$PLUGINNAME" == "" ]; then
  echo "Missing plugin name, rerun with '--help' for info."

  exit 1
fi

if [ "$PRIORITY" == "" ]; then
  echo "Missing plugin priority, rerun with '--help' for info."
  exit 1
fi

docker -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Utility 'docker' was not found, please make sure it is installed"
  echo "and available in the system path."
  echo
  exit 1
fi

rm ./template/plugin/*.rock > /dev/null 2>&1
rm ./template/plugin/*.rockspec > /dev/null 2>&1

docker run \
    --rm \
    --user root \
    --volume "$PWD/template:/template" \
    --workdir="/template/plugin" \
    -e KONG_PRIORITY_NAME="$PLUGINNAME" \
    -e KONG_PRIORITY="$PRIORITY" \
    $KONG_VERSION \
    /usr/local/openresty/luajit/bin/luajit ../priority.lua

mv ./template/plugin/*.rock ./ > /dev/null 2>&1
