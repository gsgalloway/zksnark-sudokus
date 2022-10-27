#!/usr/bin/env bash
set -e

BASEDIR=$(dirname $(readlink -f "$0"))
IMAGE=sudoku-circom

if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
    docker build -t $IMAGE $BASEDIR
fi
