# Sudoku Solution Prover

Proves knowledge of the solution to a given Sudoku puzzle.

## Run Locally

Doesn't generate a proof, but will create the trace of running the program -- which can be fed to a prover like
[SHARP](https://www.cairo-lang.org/docs/sharp.html)

```sh
./run.sh
```

To change the particular puzzle that the proof should be generated over, edit the `puzzle` and `solution` grids
in the python section of [main.cairo](./src/main.cairo#L31).

## Program Output

The first word of the output is the Ethereum address (encoded as an integer) of the user that solved the puzzle.
The second word of the output is a hash of the initial puzzle, where a value of 0 for a cell indicates that the cell's value is
omitted in the puzzle. See [here](https://github.com/starkware-libs/cairo-lang/blob/e8823212248a37cd5bf85bfb4885b89030566696/src/starkware/cairo/common/hash_chain.py)
for a reference for recreating a puzzle's hash

The program runs without error if the given solution is a valid solution, and is the solution for the given puzzle input.
