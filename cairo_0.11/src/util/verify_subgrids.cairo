from starkware.cairo.common.find_element import find_element
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem

from src.util.types import CELL_SIZE, ROW_SIZE

func verify_subgrids{range_check_ptr}(grid: felt**) -> (){
    alloc_locals;
    verify_subgrids_recursive(grid, 0);
    return ();
}

func verify_subgrids_recursive{range_check_ptr}(grid: felt**, subgrid_idx: felt){
    alloc_locals;
    if (subgrid_idx == 9){
        return ();
    }
    // This can be done without allocating new memory, but is much easier
    // to read if we just flatten each subgrid into their own contiguous arrays
    // and do `find_element()` calls on those arrays
    let (flattened: felt*) = flatten_subgrid(grid, subgrid_idx);
    verify_subgrid(flattened);
    verify_subgrids_recursive(grid, subgrid_idx+1);
    return ();
}

func verify_subgrid{range_check_ptr}(flattened_subgrid: felt*){
    alloc_locals;
    verify_subgrid_recursive(flattened_subgrid, 1);
    return ();
}

func verify_subgrid_recursive{range_check_ptr}(flattened_subgrid: felt*, target_number: felt){
    alloc_locals;
    if (target_number == 10){
        return ();
    }
    
    find_element(flattened_subgrid, CELL_SIZE, 9, target_number);
    verify_subgrid_recursive(flattened_subgrid, target_number+1);
    
    return ();
}

func flatten_subgrid{range_check_ptr}(grid: felt*, subgrid_idx: felt) -> (flattened: felt*){
    alloc_locals;

    let (flattened) = alloc();

    // Take integer division with remainder
    let divResult = unsigned_div_rem(subgrid_idx, 3);

    // subgrid_top_left_row := (subgrid_index // 3) * 3
    tempvar subgrid_top_left_row = divResult.q * 3;

    // subgrid_top_left_col := (subgrid_index % 3) * 3
    tempvar subgrid_top_left_col = divResult.r * 3;
    
    // top left
    let (idx0) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col);
    assert flattened[0] = grid[idx0];

    // top middle
    let (idx1) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col+1);
    assert flattened[1] = grid[idx1];

    // top right
    let (idx2) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col+2);
    assert flattened[2] = grid[idx2];

    // middle left
    let (idx3) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col);
    assert flattened[3] = grid[idx3];

    // middle
    let (idx4) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col+1);
    assert flattened[4] = grid[idx4];

    // middle right
    let (idx5) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col+2);
    assert flattened[5] = grid[idx5];

    // bottom left
    let (idx6) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col);
    assert flattened[6] = grid[idx6];

    // bottom middle
    let (idx7) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col+1);
    assert flattened[7] = grid[idx7];

    // bottom right
    let (idx8) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col+2);
    assert flattened[8] = grid[idx8];

    return (flattened=flattened);
}

func index_from_row_and_col(row: felt, col: felt) -> (index: felt){
    return (index=((row * ROW_SIZE) + col));
}
