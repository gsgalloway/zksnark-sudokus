#!/usr/bin/env bash
set -e

BASEDIR=$(dirname $(readlink -f "$0"))
IMAGE=gavisc/aleo-leo:latest

docker run --rm \
    -v $BASEDIR/sudoku:/sudoku \
    -w /sudoku \
    $IMAGE \
    leo build

docker run --rm \
    -v $BASEDIR/sudoku:/sudoku \
    -w /sudoku \
    $IMAGE \
    leo run verify_solution
