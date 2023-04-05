use cairo_1::sudoku_verifier;

#[test]
fn test_valid_solution() {
    let mut puzzle: Array<Array<felt252>> = ArrayTrait::new();

    let mut row_1: Array<felt252> = ArrayTrait::new();
    let mut row_2: Array<felt252> = ArrayTrait::new();
    let mut row_3: Array<felt252> = ArrayTrait::new();
    let mut row_4: Array<felt252> = ArrayTrait::new();
    let mut row_5: Array<felt252> = ArrayTrait::new();
    let mut row_6: Array<felt252> = ArrayTrait::new();
    let mut row_7: Array<felt252> = ArrayTrait::new();
    let mut row_8: Array<felt252> = ArrayTrait::new();
    let mut row_9: Array<felt252> = ArrayTrait::new();

    let is_valid = sudoku_verifier::is_valid_solution(@puzzle, @puzzle);
    assert(is_valid == true, 'invalid');
}
