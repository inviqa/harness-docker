#!/usr/bin/env bash

# shellcheck disable=SC2206
COMPOSE_BIN=($COMPOSE_BIN)

if [ "${DESTROY_ALL}" = yes ]; then
  RMI=all
else
  RMI=local
fi

run "${COMPOSE_BIN[*]}" down --rmi "${RMI}" --volumes --remove-orphans ${SHUTDOWN_TIMEOUT:+--timeout "$SHUTDOWN_TIMEOUT"}

if [ "${USE_MUTAGEN}" = yes ]; then
  run ws mutagen stop
  passthru ws mutagen rm
fi

passthru ws cleanup built-images

run rm -f .my127ws/{.flag-built,.flag-console-built}
