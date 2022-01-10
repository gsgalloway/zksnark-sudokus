%builtins output range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word

from contracts.util.verify_rows import verify_rows
from contracts.util.verify_columns import verify_columns
from contracts.util.verify_subgrids import verify_subgrids
from contracts.util.verify_puzzle_matches_solution import verify_puzzle_matches_solution
from contracts.util.types import NUM_CELLS, CELL_SIZE

# cells without a value provided in the initial puzzle are assumed to have a value of 0
const SENTINEL_CELL_UNSET = 0

func main{output_ptr: felt*, range_check_ptr}():
    alloc_locals
    let (local solution: felt**) = alloc()
    let (local puzzle: felt**) = alloc()
    %{
        _ = ids.SENTINEL_CELL_UNSET
        puzzle = [
            [_, _, _,  2, 6, _,  7, _, 1],
            [6, 8, _,  _, 7, _,  _, 9, _],
            [1, 9, _,  _, _, 4,  5, _, _],
            
            [8, 2, _,  1, _, _,  _, 4, _],
            [_, _, 4,  6, _, 2,  9, _, _],
            [_, 5, _,  _, _, 3,  _, 2, 8],

            [_, _, 9,  3, _, _,  _, 7, 4],
            [_, 4, _,  _, 5, _,  _, 3, 6],
            [7, _, 3,  _, 1, 8,  _, _, _]
        ]
        for row in range(9):
            for col in range(9):
                offset = row * 9 + col
                memory[ids.puzzle + offset] = puzzle[row][col]

        solution = [
            [4, 3, 5,  2, 6, 9,  7, 8, 1],
            [6, 8, 2,  5, 7, 1,  4, 9, 3],
            [1, 9, 7,  8, 3, 4,  5, 6, 2],
            
            [8, 2, 6,  1, 9, 5,  3, 4, 7],
            [3, 7, 4,  6, 8, 2,  9, 1, 5],
            [9, 5, 1,  7, 4, 3,  6, 2, 8],

            [5, 1, 9,  3, 2, 6,  8, 7, 4],
            [2, 4, 8,  9, 5, 7,  1, 3, 6],
            [7, 6, 3,  4, 1, 8,  2, 5, 9]
        ]
        for row in range(9):
            for col in range(9):
                offset = row * 9 + col
                memory[ids.solution + offset] = solution[row][col]
    %}

    # Check solution is valid
    verify_rows(solution)
    verify_columns(solution)
    verify_subgrids(solution)

    # # Confirm input puzzle matches the given solution
    verify_puzzle_matches_solution(puzzle, solution)

    # The puzzle's solution should be private but the puzzle
    # itself should be output publicly so a verifier can
    # identify which puzzle the prover solved.
    serialize_puzzle(puzzle)

    return ()
end

func serialize_puzzle{output_ptr: felt*}(puzzle: felt*):
    alloc_locals
    serialize_puzzle_recursive(puzzle, NUM_CELLS)
    return ()
end

func serialize_puzzle_recursive{output_ptr: felt*}(puzzle: felt*, size: felt):
    alloc_locals
    if size == 0:
        return ()
    end
    serialize_word(puzzle[0])
    serialize_puzzle_recursive(puzzle+1, size-1)
    return ()
end
