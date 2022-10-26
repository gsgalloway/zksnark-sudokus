// The 'sudoku' program.
program sudoku.aleo {
    struct Row {
        c1: u8,
        c2: u8,
        c3: u8,
        c4: u8,
        c5: u8,
        c6: u8,
        c7: u8,
        c8: u8,
        c9: u8,
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

    transition verify_solution(public puzzle: Board, solution: Board) -> u8 {
        let ret: u8 = puzzle.r1.c1 + 1u8;
        return ret;
    }
}
