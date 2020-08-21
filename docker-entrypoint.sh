#!/bin/bash

function defaults {
    : ${DEVPISERVER_SERVERDIR="/data/server"}
    : ${DEVPISERVER_RESTRICT_MODIFY="root"}
    : ${DEVPISERVER_HOST="127.0.0.1"}
    : ${DEVPISERVER_PORT="3141"}
    : ${DEVPISERVER_CLIENTDIR="/data/client"}

    echo "DEVPISERVER_SERVERDIR is ${DEVPISERVER_SERVERDIR}"
    echo "DEVPISERVER_CLIENTDIR is ${DEVPISERVER_CLIENTDIR}"
    echo "DEVPISERVER_RESTRICT_MODIFY is ${DEVPISERVER_RESTRICT_MODIFY}"
    echo "DEVPISERVER_HOST is ${DEVPISERVER_HOST}"
    echo "DEVPISERVER_PORT is ${DEVPISERVER_PORT}"

    export DEVPISERVER_SERVERDIR DEVPISERVER_CLIENTDIR DEVPISERVER_RESTRICT_MODIFY DEVPISERVER_HOST DEVPISERVER_PORT
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"
    devpi-init
    devpi-server --restrict-modify root --host 127.0.0.1 --port 3141
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPISERVER_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
