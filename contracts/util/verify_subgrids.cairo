from starkware.cairo.common.find_element import find_element
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem

from contracts.util.types import CELL_SIZE, ROW_SIZE

func verify_subgrids{range_check_ptr}(grid: felt**):
    alloc_locals
    verify_subgrids_recursive(grid, 0)
    return ()
end

func verify_subgrids_recursive{range_check_ptr}(grid: felt**, subgrid_idx: felt):
    alloc_locals
    if subgrid_idx == 9:
        return ()
    end
    # This can be done without allocating new memory, but is much easier
    # to read if we just flatten each subgrid into their own contiguous arrays
    # and do `find_element()` calls on those arrays
    let (flattened: felt*) = flatten_subgrid(grid, subgrid_idx)
    verify_subgrid(flattened)
    verify_subgrids_recursive(grid, subgrid_idx+1)
    return ()
end

func verify_subgrid{range_check_ptr}(flattened_subgrid: felt*):
    alloc_locals
    verify_subgrid_recursive(flattened_subgrid, 1)
    return ()
end

func verify_subgrid_recursive{range_check_ptr}(flattened_subgrid: felt*, target_number: felt):
    alloc_locals
    if target_number == 10:
        return ()
    end
    
    find_element(flattened_subgrid, CELL_SIZE, 9, target_number)
    verify_subgrid_recursive(flattened_subgrid, target_number+1)
    
    return ()
end

func flatten_subgrid{range_check_ptr}(grid: felt*, subgrid_idx: felt) -> (flattened: felt*):
    alloc_locals

    let (flattened) = alloc()

    # Take integer division with remainder
    let divResult = unsigned_div_rem(subgrid_idx, 3)

    # subgrid_top_left_row := (subgrid_index // 3) * 3
    tempvar subgrid_top_left_row = divResult.q * 3

    # subgrid_top_left_col := (subgrid_index % 3) * 3
    tempvar subgrid_top_left_col = divResult.r * 3
    
    # top left
    let (idx0) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col)
    assert flattened[0] = grid[idx0]

    # top middle
    let (idx1) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col+1)
    assert flattened[1] = grid[idx1]

    # top right
    let (idx2) = index_from_row_and_col(subgrid_top_left_row, subgrid_top_left_col+2)
    assert flattened[2] = grid[idx2]

    # middle left
    let (idx3) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col)
    assert flattened[3] = grid[idx3]

    # middle
    let (idx4) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col+1)
    assert flattened[4] = grid[idx4]

    # middle right
    let (idx5) = index_from_row_and_col(subgrid_top_left_row+1, subgrid_top_left_col+2)
    assert flattened[5] = grid[idx5]

    # bottom left
    let (idx6) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col)
    assert flattened[6] = grid[idx6]

    # bottom middle
    let (idx7) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col+1)
    assert flattened[7] = grid[idx7]

    # bottom right
    let (idx8) = index_from_row_and_col(subgrid_top_left_row+2, subgrid_top_left_col+2)
    assert flattened[8] = grid[idx8]

    return (flattened)
end

func index_from_row_and_col(row: felt, col: felt) -> (index: felt):
    return ((row * ROW_SIZE) + col)
end

# 0,  1,  2,   3,  4,  5    6,  7,  8
# 9,  10, 11,  12, 13, 14,  15, 16, 17
# 18, 19, 20,  21, 22, 23,  24, 25, 26

# 27, 28, 29,  30, 31, 32,  33, 34, 35
# 36, 37, 38,  39, 40, 41,  42, 43, 44
# 45, 46, 47,  48, 49, 50,  51, 52, 53

# 54, 55, 56,  57, 58, 59,  60, 61, 62
# 63, 64, 65,  66, 67, 68,  69, 70, 71
# 72, 73, 74,  75, 76, 77,  78, 79, 80


# subgrid 0:
# 0, 1, 2
# 9, 10, 11
# 18, 19, 20

# subgrid 1:
# 3, 4, 5
# 12, 13, 14,
# 21, 22, 23

# subgrid 3:
# top_left_row = 3
# top_left_col = 0
# 27, 28, 29

# subgrid 6:
# subgrid_top_left_row := 6 // 3 = 2

# subgrid x:


# top left rows:
# 0: 0
# 1: 0
# 2: 0
# 3: 3
# 4: 3
# 5: 3
# 6: 6
# 7: 6
# 8: 6
# x: (x // 3) * 3
