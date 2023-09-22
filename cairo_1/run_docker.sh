#!/usr/bin/env bash
set -e

BASEDIR=$(dirname $(readlink -f "$0"))
IMAGE="sudoku-cairo-1.0"

docker build --platform linux/x86_64 -t $IMAGE $BASEDIR

docker run --rm \
    --platform linux/x86_64 \
    -v $BASEDIR:/sudoku \
    -w /sudoku \
    -e RUST_BACKTRACE=1 \
    -it \
    $IMAGE \
    scarb run test
