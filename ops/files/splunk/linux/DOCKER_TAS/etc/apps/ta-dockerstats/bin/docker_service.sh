#!/bin/bash

DOCKER_BIN=$(which docker)
"$DOCKER_BIN" service ls  \
  | tail -n +2 \
  | sed -e "s/,/ /g" \
  | sed -E "s/\s\s+/,/g"
