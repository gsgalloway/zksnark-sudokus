# Sudoku Solution Prover

Proves knowledge of the solution to a given Sudoku puzzle.

## Setup

With python >= 3.7:

```sh
pip install -r requirements.txt
```

## Compile

```sh
make compile
```

## Calculate Program Hash

Returns the hash of the program, excluding any inputs and outputs. Used to by verifiers to cheaply identify 
proofs that are generated for this particular program.

```sh
make program-hash
```

## Run Locally

Doesn't generate a proof, but will create the trace of running the program -- which can be fed to a prover like
[SHARP](https://www.cairo-lang.org/docs/sharp.html)

```sh
make run
```

To change the particular puzzle that the proof should be generated over, edit the `puzzle` and `solution` grids
in the python section of [main.cairo](./contracts/main.cairo).

## Program Output

The first word of the output is the Ethereum address (encoded as an integer) of the user that solved the puzzle.
The second word of the output is a hash of the initial puzzle, where a value of 0 for a cell indicates that the cell's value is
omitted in the puzzle. See [here](https://github.com/starkware-libs/cairo-lang/blob/e8823212248a37cd5bf85bfb4885b89030566696/src/starkware/cairo/common/hash_chain.py)
for a reference for recreating a puzzle's hash

The program runs without error if the given solution is a valid solution, and corresponds to the given puzzle input.
This could be make more cost efficient by outputting a hash of the puzzle instead of the whole puzzle.
