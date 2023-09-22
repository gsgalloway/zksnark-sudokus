from src.util.types import NUM_CELLS

func verify_puzzle_matches_solution(puzzle: felt*, solution: felt*) -> (){
    verify_puzzle_matches_solution_recursive(puzzle, solution, 0);
    return ();
}

func verify_puzzle_matches_solution_recursive(puzzle: felt*, solution: felt*, index: felt){
    if (index == NUM_CELLS){
        return ();
    }

    if (puzzle[index] != 0){
        assert puzzle[index] = solution[index];
    }

    verify_puzzle_matches_solution_recursive(puzzle, solution, index + 1);

    return ();
}
