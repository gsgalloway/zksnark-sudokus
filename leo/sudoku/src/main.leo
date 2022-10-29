// The 'sudoku' program.
program sudoku.aleo {
    struct Row {
        c1: u16,
        c2: u16,
        c3: u16,
        c4: u16,
        c5: u16,
        c6: u16,
        c7: u16,
        c8: u16,
        c9: u16,
    }
    struct Board {
        r1: Row,
        r2: Row,
        r3: Row,
        r4: Row,
        r5: Row,
        r6: Row,
        r7: Row,
        r8: Row,
        r9: Row,
    }

    struct NineDigitsPart1 {
        n1: u16,
        n2: u16,
        n3: u16,
        n4: u16,
    }
    struct NineDigitsPart2 {
        n5: u16,
        n6: u16,
        n7: u16,
        n8: u16,
        n9: u16
    }

    record PuzzleSolved {
        owner: address,
        gates: u64,
        puzzle: Board,
    }

    transition verify_solution(solver: address, public puzzle: Board, solution: Board) -> PuzzleSolved {
        // check the rows
        let rows_valid: bool =
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c1, n2: solution.r1.c2, n3: solution.r1.c3, n4: solution.r1.c4},
                NineDigitsPart2{n5: solution.r1.c5, n6: solution.r1.c6, n7: solution.r1.c7, n8: solution.r1.c8, n9: solution.r1.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r2.c1, n2: solution.r2.c2, n3: solution.r2.c3, n4: solution.r2.c4},
                NineDigitsPart2{n5: solution.r2.c5, n6: solution.r2.c6, n7: solution.r2.c7, n8: solution.r2.c8, n9: solution.r2.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r3.c1, n2: solution.r3.c2, n3: solution.r3.c3, n4: solution.r3.c4},
                NineDigitsPart2{n5: solution.r3.c5, n6: solution.r3.c6, n7: solution.r3.c7, n8: solution.r3.c8, n9: solution.r3.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r4.c1, n2: solution.r4.c2, n3: solution.r4.c3, n4: solution.r4.c4},
                NineDigitsPart2{n5: solution.r4.c5, n6: solution.r4.c6, n7: solution.r4.c7, n8: solution.r4.c8, n9: solution.r4.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r5.c1, n2: solution.r5.c2, n3: solution.r5.c3, n4: solution.r5.c4},
                NineDigitsPart2{n5: solution.r5.c5, n6: solution.r5.c6, n7: solution.r5.c7, n8: solution.r5.c8, n9: solution.r5.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r6.c1, n2: solution.r6.c2, n3: solution.r6.c3, n4: solution.r6.c4},
                NineDigitsPart2{n5: solution.r6.c5, n6: solution.r6.c6, n7: solution.r6.c7, n8: solution.r6.c8, n9: solution.r6.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r7.c1, n2: solution.r7.c2, n3: solution.r7.c3, n4: solution.r7.c4},
                NineDigitsPart2{n5: solution.r7.c5, n6: solution.r7.c6, n7: solution.r7.c7, n8: solution.r7.c8, n9: solution.r7.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r8.c1, n2: solution.r8.c2, n3: solution.r8.c3, n4: solution.r8.c4},
                NineDigitsPart2{n5: solution.r8.c5, n6: solution.r8.c6, n7: solution.r8.c7, n8: solution.r8.c8, n9: solution.r8.c9},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r9.c1, n2: solution.r9.c2, n3: solution.r9.c3, n4: solution.r9.c4},
                NineDigitsPart2{n5: solution.r9.c5, n6: solution.r9.c6, n7: solution.r9.c7, n8: solution.r9.c8, n9: solution.r9.c9},
            );
        console.assert(rows_valid);

        // check the columns
        let cols_valid: bool =
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c1, n2: solution.r2.c1, n3: solution.r3.c1, n4: solution.r4.c1},
                NineDigitsPart2{n5: solution.r5.c1, n6: solution.r6.c1, n7: solution.r7.c1, n8: solution.r8.c1, n9: solution.r9.c1},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c2, n2: solution.r2.c2, n3: solution.r3.c2, n4: solution.r4.c2},
                NineDigitsPart2{n5: solution.r5.c2, n6: solution.r6.c2, n7: solution.r7.c2, n8: solution.r8.c2, n9: solution.r9.c2},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c3, n2: solution.r2.c3, n3: solution.r3.c3, n4: solution.r4.c3},
                NineDigitsPart2{n5: solution.r5.c3, n6: solution.r6.c3, n7: solution.r7.c3, n8: solution.r8.c3, n9: solution.r9.c3},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c4, n2: solution.r2.c4, n3: solution.r3.c4, n4: solution.r4.c4},
                NineDigitsPart2{n5: solution.r5.c4, n6: solution.r6.c4, n7: solution.r7.c4, n8: solution.r8.c4, n9: solution.r9.c4},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c5, n2: solution.r2.c5, n3: solution.r3.c5, n4: solution.r4.c5},
                NineDigitsPart2{n5: solution.r5.c5, n6: solution.r6.c5, n7: solution.r7.c5, n8: solution.r8.c5, n9: solution.r9.c5},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c6, n2: solution.r2.c6, n3: solution.r3.c6, n4: solution.r4.c6},
                NineDigitsPart2{n5: solution.r5.c6, n6: solution.r6.c6, n7: solution.r7.c6, n8: solution.r8.c6, n9: solution.r9.c6},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c7, n2: solution.r2.c7, n3: solution.r3.c7, n4: solution.r4.c7},
                NineDigitsPart2{n5: solution.r5.c7, n6: solution.r6.c7, n7: solution.r7.c7, n8: solution.r8.c7, n9: solution.r9.c7},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c8, n2: solution.r2.c8, n3: solution.r3.c8, n4: solution.r4.c8},
                NineDigitsPart2{n5: solution.r5.c8, n6: solution.r6.c8, n7: solution.r7.c8, n8: solution.r8.c8, n9: solution.r9.c8},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c9, n2: solution.r2.c9, n3: solution.r3.c9, n4: solution.r4.c9},
                NineDigitsPart2{n5: solution.r5.c9, n6: solution.r6.c9, n7: solution.r7.c9, n8: solution.r8.c9, n9: solution.r9.c9},
            );
        console.assert(cols_valid);
        
        // check the 3x3 squares
        let squares_valid: bool = 
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c1, n2: solution.r1.c2, n3: solution.r1.c3, n4: solution.r2.c1},
                NineDigitsPart2{n5: solution.r2.c2, n6: solution.r2.c3, n7: solution.r3.c1, n8: solution.r3.c2, n9: solution.r3.c3},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c4, n2: solution.r1.c5, n3: solution.r1.c6, n4: solution.r2.c4},
                NineDigitsPart2{n5: solution.r2.c5, n6: solution.r2.c6, n7: solution.r3.c4, n8: solution.r3.c5, n9: solution.r3.c6},
            ) &&
            check_all_nine_digits(
                NineDigitsPart1{n1: solution.r1.c7, n2: solution.r1.c8, n3: solution.r1.c9, n4: solution.r2.c7},
                NineDigitsPart2{n5: solution.r2.c8, n6: solution.r2.c9, n7: solution.r3.c7, n8: solution.r3.c8, n9: solution.r3.c9},
            );
            // *** Note: At this point we've hit a limit for the max circuit size supported by the Aleo VM. ***
            // Enabling any of the remaining 6 square checks results in
            // Error [ECLI0377008]: Failed to execute the `aleo build` command.
            // SnarkVM Error: marlin: IndexTooLarge(1572863, 2097152)
            //
            // This limit on max number of circuit constraints should be raised soon:
            // https://discord.com/channels/700454073459015690/745897257160933516/1029564953138581524
            
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r4.c1, n2: solution.r4.c2, n3: solution.r4.c3, n4: solution.r5.c1},
            //     NineDigitsPart2{n5: solution.r5.c2, n6: solution.r5.c3, n7: solution.r6.c1, n8: solution.r6.c2, n9: solution.r6.c3},
            // )
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r4.c4, n2: solution.r4.c5, n3: solution.r4.c6, n4: solution.r5.c4},
            //     NineDigitsPart2{n5: solution.r5.c5, n6: solution.r5.c6, n7: solution.r6.c4, n8: solution.r6.c5, n9: solution.r6.c6},
            // ) &&
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r4.c7, n2: solution.r4.c8, n3: solution.r4.c9, n4: solution.r5.c7},
            //     NineDigitsPart2{n5: solution.r5.c8, n6: solution.r5.c9, n7: solution.r6.c7, n8: solution.r6.c8, n9: solution.r6.c9},
            // ) &&
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r7.c1, n2: solution.r7.c2, n3: solution.r7.c3, n4: solution.r8.c1},
            //     NineDigitsPart2{n5: solution.r8.c2, n6: solution.r8.c3, n7: solution.r9.c1, n8: solution.r9.c2, n9: solution.r9.c3},
            // ) &&
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r7.c4, n2: solution.r7.c5, n3: solution.r7.c6, n4: solution.r8.c4},
            //     NineDigitsPart2{n5: solution.r8.c5, n6: solution.r8.c6, n7: solution.r9.c4, n8: solution.r9.c5, n9: solution.r9.c6},
            // ) &&
            // check_all_nine_digits(
            //     NineDigitsPart1{n1: solution.r7.c7, n2: solution.r7.c8, n3: solution.r7.c9, n4: solution.r8.c7},
            //     NineDigitsPart2{n5: solution.r8.c8, n6: solution.r8.c9, n7: solution.r9.c7, n8: solution.r9.c8, n9: solution.r9.c9},
            // );
        console.assert(squares_valid);

        // confirm solution matches the puzzle
        console.assert(solution_matches_puzzle(puzzle, solution));

        return PuzzleSolved {
            owner: solver,
            gates: 0u64,
            puzzle: puzzle,
        };
    }

    // Checks for the presence of all numbers 1-9 in a given list of numbers.
    // There are a few limitations for passing these 9 values to this helper function:
    //  - Function arguments are limited to 8 args max
    //  - There are only structs, not yet tuples or arrays
    //  - Structs can have 9 elements, but the Leo compiler won't create valid Aleo when trying to inline initialize a 9-element struct
    // To work around this problem, the parameters are passed in via two structs.
    function check_all_nine_digits(part1: NineDigitsPart1, part2: NineDigitsPart2) -> bool {
        // We don't have hashsets or constant-time array lookups via prover hints, but we
        // do have bitwise operations! So we can use a bitmap as a set.
        // Note that subtraction is automatically safe from underflow in Aleo.
        let bitshift_1: u16 = part1.n1 - 1u16;
        let bitshift_2: u16 = part1.n2 - 1u16;
        let bitshift_3: u16 = part1.n3 - 1u16;
        let bitshift_4: u16 = part1.n4 - 1u16;
        let bitshift_5: u16 = part2.n5 - 1u16;
        let bitshift_6: u16 = part2.n6 - 1u16;
        let bitshift_7: u16 = part2.n7 - 1u16;
        let bitshift_8: u16 = part2.n8 - 1u16;
        let bitshift_9: u16 = part2.n9 - 1u16;
        let bitmap: u16 = 
            (1u16<<(bitshift_1)) |
            (1u16<<(bitshift_2)) |
            (1u16<<(bitshift_3)) |
            (1u16<<(bitshift_4)) |
            (1u16<<(bitshift_5)) |
            (1u16<<(bitshift_6)) |
            (1u16<<(bitshift_7)) |
            (1u16<<(bitshift_8)) |
            (1u16<<(bitshift_9));

        // The full bitmap, 0b111111111 == 511
        return (bitmap == 511u16);
    }

    function solution_matches_puzzle(puzzle: Board, solution: Board) -> bool {
        return
            // row 1
            (puzzle.r1.c1 == 0u16 || puzzle.r1.c1 == solution.r1.c1) &&
            (puzzle.r1.c2 == 0u16 || puzzle.r1.c2 == solution.r1.c2) &&
            (puzzle.r1.c3 == 0u16 || puzzle.r1.c3 == solution.r1.c3) &&
            (puzzle.r1.c4 == 0u16 || puzzle.r1.c4 == solution.r1.c4) &&
            (puzzle.r1.c5 == 0u16 || puzzle.r1.c5 == solution.r1.c5) &&
            (puzzle.r1.c6 == 0u16 || puzzle.r1.c6 == solution.r1.c6) &&
            (puzzle.r1.c7 == 0u16 || puzzle.r1.c7 == solution.r1.c7) &&
            (puzzle.r1.c8 == 0u16 || puzzle.r1.c8 == solution.r1.c8) &&
            (puzzle.r1.c9 == 0u16 || puzzle.r1.c9 == solution.r1.c9) &&
            // row 2
            (puzzle.r2.c1 == 0u16 || puzzle.r2.c1 == solution.r2.c1) &&
            (puzzle.r2.c2 == 0u16 || puzzle.r2.c2 == solution.r2.c2) &&
            (puzzle.r2.c3 == 0u16 || puzzle.r2.c3 == solution.r2.c3) &&
            (puzzle.r2.c4 == 0u16 || puzzle.r2.c4 == solution.r2.c4) &&
            (puzzle.r2.c5 == 0u16 || puzzle.r2.c5 == solution.r2.c5) &&
            (puzzle.r2.c6 == 0u16 || puzzle.r2.c6 == solution.r2.c6) &&
            (puzzle.r2.c7 == 0u16 || puzzle.r2.c7 == solution.r2.c7) &&
            (puzzle.r2.c8 == 0u16 || puzzle.r2.c8 == solution.r2.c8) &&
            (puzzle.r2.c9 == 0u16 || puzzle.r2.c9 == solution.r2.c9) &&
            // row 3
            (puzzle.r3.c1 == 0u16 || puzzle.r3.c1 == solution.r3.c1) &&
            (puzzle.r3.c2 == 0u16 || puzzle.r3.c2 == solution.r3.c2) &&
            (puzzle.r3.c3 == 0u16 || puzzle.r3.c3 == solution.r3.c3) &&
            (puzzle.r3.c4 == 0u16 || puzzle.r3.c4 == solution.r3.c4) &&
            (puzzle.r3.c5 == 0u16 || puzzle.r3.c5 == solution.r3.c5) &&
            (puzzle.r3.c6 == 0u16 || puzzle.r3.c6 == solution.r3.c6) &&
            (puzzle.r3.c7 == 0u16 || puzzle.r3.c7 == solution.r3.c7) &&
            (puzzle.r3.c8 == 0u16 || puzzle.r3.c8 == solution.r3.c8) &&
            (puzzle.r3.c9 == 0u16 || puzzle.r3.c9 == solution.r3.c9) &&
            // row 4
            (puzzle.r4.c1 == 0u16 || puzzle.r4.c1 == solution.r4.c1) &&
            (puzzle.r4.c2 == 0u16 || puzzle.r4.c2 == solution.r4.c2) &&
            (puzzle.r4.c3 == 0u16 || puzzle.r4.c3 == solution.r4.c3) &&
            (puzzle.r4.c4 == 0u16 || puzzle.r4.c4 == solution.r4.c4) &&
            (puzzle.r4.c5 == 0u16 || puzzle.r4.c5 == solution.r4.c5) &&
            (puzzle.r4.c6 == 0u16 || puzzle.r4.c6 == solution.r4.c6) &&
            (puzzle.r4.c7 == 0u16 || puzzle.r4.c7 == solution.r4.c7) &&
            (puzzle.r4.c8 == 0u16 || puzzle.r4.c8 == solution.r4.c8) &&
            (puzzle.r4.c9 == 0u16 || puzzle.r4.c9 == solution.r4.c9) &&
            // row 5
            (puzzle.r5.c1 == 0u16 || puzzle.r5.c1 == solution.r5.c1) &&
            (puzzle.r5.c2 == 0u16 || puzzle.r5.c2 == solution.r5.c2) &&
            (puzzle.r5.c3 == 0u16 || puzzle.r5.c3 == solution.r5.c3) &&
            (puzzle.r5.c4 == 0u16 || puzzle.r5.c4 == solution.r5.c4) &&
            (puzzle.r5.c5 == 0u16 || puzzle.r5.c5 == solution.r5.c5) &&
            (puzzle.r5.c6 == 0u16 || puzzle.r5.c6 == solution.r5.c6) &&
            (puzzle.r5.c7 == 0u16 || puzzle.r5.c7 == solution.r5.c7) &&
            (puzzle.r5.c8 == 0u16 || puzzle.r5.c8 == solution.r5.c8) &&
            (puzzle.r5.c9 == 0u16 || puzzle.r5.c9 == solution.r5.c9) &&
            // row 6
            (puzzle.r6.c1 == 0u16 || puzzle.r6.c1 == solution.r6.c1) &&
            (puzzle.r6.c2 == 0u16 || puzzle.r6.c2 == solution.r6.c2) &&
            (puzzle.r6.c3 == 0u16 || puzzle.r6.c3 == solution.r6.c3) &&
            (puzzle.r6.c4 == 0u16 || puzzle.r6.c4 == solution.r6.c4) &&
            (puzzle.r6.c5 == 0u16 || puzzle.r6.c5 == solution.r6.c5) &&
            (puzzle.r6.c6 == 0u16 || puzzle.r6.c6 == solution.r6.c6) &&
            (puzzle.r6.c7 == 0u16 || puzzle.r6.c7 == solution.r6.c7) &&
            (puzzle.r6.c8 == 0u16 || puzzle.r6.c8 == solution.r6.c8) &&
            (puzzle.r6.c9 == 0u16 || puzzle.r6.c9 == solution.r6.c9) &&
            // row 7
            (puzzle.r7.c1 == 0u16 || puzzle.r7.c1 == solution.r7.c1) &&
            (puzzle.r7.c2 == 0u16 || puzzle.r7.c2 == solution.r7.c2) &&
            (puzzle.r7.c3 == 0u16 || puzzle.r7.c3 == solution.r7.c3) &&
            (puzzle.r7.c4 == 0u16 || puzzle.r7.c4 == solution.r7.c4) &&
            (puzzle.r7.c5 == 0u16 || puzzle.r7.c5 == solution.r7.c5) &&
            (puzzle.r7.c6 == 0u16 || puzzle.r7.c6 == solution.r7.c6) &&
            (puzzle.r7.c7 == 0u16 || puzzle.r7.c7 == solution.r7.c7) &&
            (puzzle.r7.c8 == 0u16 || puzzle.r7.c8 == solution.r7.c8) &&
            (puzzle.r7.c9 == 0u16 || puzzle.r7.c9 == solution.r7.c9) &&
            // row 8
            (puzzle.r8.c1 == 0u16 || puzzle.r8.c1 == solution.r8.c1) &&
            (puzzle.r8.c2 == 0u16 || puzzle.r8.c2 == solution.r8.c2) &&
            (puzzle.r8.c3 == 0u16 || puzzle.r8.c3 == solution.r8.c3) &&
            (puzzle.r8.c4 == 0u16 || puzzle.r8.c4 == solution.r8.c4) &&
            (puzzle.r8.c5 == 0u16 || puzzle.r8.c5 == solution.r8.c5) &&
            (puzzle.r8.c6 == 0u16 || puzzle.r8.c6 == solution.r8.c6) &&
            (puzzle.r8.c7 == 0u16 || puzzle.r8.c7 == solution.r8.c7) &&
            (puzzle.r8.c8 == 0u16 || puzzle.r8.c8 == solution.r8.c8) &&
            (puzzle.r8.c9 == 0u16 || puzzle.r8.c9 == solution.r8.c9) &&
            // row 9
            (puzzle.r9.c1 == 0u16 || puzzle.r9.c1 == solution.r9.c1) &&
            (puzzle.r9.c2 == 0u16 || puzzle.r9.c2 == solution.r9.c2) &&
            (puzzle.r9.c3 == 0u16 || puzzle.r9.c3 == solution.r9.c3) &&
            (puzzle.r9.c4 == 0u16 || puzzle.r9.c4 == solution.r9.c4) &&
            (puzzle.r9.c5 == 0u16 || puzzle.r9.c5 == solution.r9.c5) &&
            (puzzle.r9.c6 == 0u16 || puzzle.r9.c6 == solution.r9.c6) &&
            (puzzle.r9.c7 == 0u16 || puzzle.r9.c7 == solution.r9.c7) &&
            (puzzle.r9.c8 == 0u16 || puzzle.r9.c8 == solution.r9.c8) &&
            (puzzle.r9.c9 == 0u16 || puzzle.r9.c9 == solution.r9.c9);
    }
}
