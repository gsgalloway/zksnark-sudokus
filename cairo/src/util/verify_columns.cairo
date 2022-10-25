from starkware.cairo.common.find_element import find_element

from contracts.util.types import CELL_SIZE, COLUMN_SIZE

func verify_columns{range_check_ptr}(grid: felt**):
    alloc_locals
    verify_columns_recursive(grid, 0)
    return ()
end

func verify_columns_recursive{range_check_ptr}(grid: felt**, column_idx: felt):
    alloc_locals
    if column_idx == 9:
        return ()
    end
    verify_column(grid, column_idx)
    verify_columns_recursive(grid, column_idx+1)
    return ()
end

func verify_column{range_check_ptr}(grid: felt**, column_idx: felt):
    alloc_locals
    verify_column_recursive(grid, column_idx, 1)
    return ()
end

func verify_column_recursive{range_check_ptr}(grid: felt**, column_idx: felt, target_number: felt):
    alloc_locals
    if target_number == 10:
        return ()
    end
    
    tempvar column: felt* = grid + (CELL_SIZE * column_idx)
    find_element(column, COLUMN_SIZE, 9, target_number)
    verify_column_recursive(grid, column_idx, target_number+1)
    return ()
end
