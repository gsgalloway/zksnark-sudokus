from starkware.cairo.common.find_element import find_element

from src.util.types import ROW_SIZE, CELL_SIZE

func verify_rows{range_check_ptr}(grid: felt**) {
    alloc_locals;
    verify_rows_recursive(grid, 0);
    return ();
}

func verify_rows_recursive{range_check_ptr}(grid: felt**, row_idx: felt){
    alloc_locals;
    if (row_idx == 9) {
        return ();
    }
    verify_row(grid, row_idx);
    verify_rows_recursive(grid, row_idx+1);
    return ();
}

func verify_row{range_check_ptr}(grid: felt**, row_idx: felt){
    alloc_locals;
    verify_row_recursive(grid, row_idx, 1);
    return ();
}

func verify_row_recursive{range_check_ptr}(grid: felt**, row_idx: felt, target_number: felt){
    alloc_locals;
    if (target_number == 10){
        return ();
    }
    
    tempvar row: felt* = grid + (row_idx * ROW_SIZE);
    find_element(row, CELL_SIZE, 9, target_number);
    verify_row_recursive(grid, row_idx, target_number+1);
    return ();
}
