#!/bin/bash
FILE=${WALLET_HOME}/${COIN}.conf
if [ ! -f "${FILE}" ]; then
    cp /home/${COIN}.conf ${FILE}
fi

$BIN_HOME/$DAEMON_NAME --daemon & trap : TERM INT; sleep infinity & wait