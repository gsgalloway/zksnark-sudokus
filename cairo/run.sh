#!/usr/bin/env bash
set -e

BASEDIR=$(dirname $(readlink -f "$0"))
IMAGE=sudoku-cairo

if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
    docker build -t $IMAGE $BASEDIR
fi

docker run --rm \
    -v $BASEDIR:/sudoku \
    $IMAGE \
    cairo-compile './src/main.cairo' --output './src/main_compiled.json'

docker run --rm \
    -v $BASEDIR:/sudoku \
    $IMAGE \
    cairo-run --program='./src/main_compiled.json' --layout=small --print_output
