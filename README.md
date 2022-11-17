# SNARK Sudoku Verifiers

A showcase of implementing the same toy zk circuit in various SNARK tools and libraries.

## Toy Circuit Spec

The circuit must take as input both a public 9x9 board representing the puzzle, and a corresponding
private 9x9 solution. The circuit should verify that the given solution is a valid sudoku board,
and that it correctly maps to the given board. Un-filled cells in the puzzle are represented as cells
with a zero value.

A sudoku verifier is a useful problem to showcase in that:

- The inherent logic in a sudoku verifier is non-trivial, but not overly large. Ideas like decomposition, code-reuse, and readability come into scope for a problem of this size
- There are multiple different approaches to verifying a row/column/square, each requiring different language features. Some SNARK tools more naturally fit to one approach over another, which highlights the differences between them
- It can illustrate a valid (if contrived) use-case for private inputs into snark circuits. In this case, one imagines a dapp in which users compete against one another to solve published sudoku puzzles, and must submit proof of knowledge of the solutions to a decentralized app without exposing the solution itself
- It showcases the use of a simple constraint built on a conditional expression (each cell in the solution must equal the corresponding cell in the puzzle unless that puzzle cell is unset)

It is not as useful for showcasing:

- A SNARK tool's flexibility for hardcore optimization

### Verifying a Row/Column/Square

A program can check a row/column/square correctly contains the numbers 1 through 9 in any of the following ways:

1. Use a set. The program can either use the set to check for duplicates (assuming all cell values are between 1 and 9) or fill the set with all nine cells' values and check it for equality against an expected set. A couple of common implementations for sets make use of either an underlying hash table or bitset.
1. Check that all values are contained in [1-9], are unique, and sum to 45. This is a moderately imperative approach, but it can be built using two extremely simple and widely implemented primitives: `add` and `assert_equal`
1. Check that the given list of 9 numbers is a permutation of the list of numbers 1 through 9. PLONK and its derivatives rely on permutation checks as part of their proof system, but do not necessarily expose this functionality nicely to developer code
2. Make use of prover hints and encode into the witness the indices of all numbers 1 through 9 in the given list of cells.

## Implementations

Each subfolder captures a sudoku implementation for the given SNARK tool, along with a README with discussion of that particular implementation and instructions for running locally.
