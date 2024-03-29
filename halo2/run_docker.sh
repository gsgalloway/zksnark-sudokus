#!/usr/bin/env bash
set -e

BASEDIR=$(dirname $(readlink -f "$0"))
IMAGE="sudoku-halo2"

docker build -t $IMAGE $BASEDIR

docker run --rm \
    -v $BASEDIR:/sudoku \
    -w /sudoku \
    -e RUST_BACKTRACE=1 \
    -it \
    $IMAGE \
    cargo test
