pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
  signal input puzzle[9][9];
  signal input solution[9][9];
  signal output out;

  // Check all values less than 10
  component checkInRange = checkNumbersInRange();
  for (var row = 0; row<9; row++) {
    for (var col = 0; col<9; col++) {
      checkInRange.solution[row][col] <== solution[row][col];
    }
  }

  // check the rows
  component checkRows = checkRows();
  for (var row = 0; row<9; row++) {
    for (var col = 0; col<9; col++) {
      checkRows.solution[row][col] <== solution[row][col];
    }
  }

  // check the columns
  component checkCols = checkColumns();
  for (var row = 0; row<9; row++) {
    for (var col = 0; col<9; col++) {
      checkCols.solution[row][col] <== solution[row][col];
    }
  }

  // check the squares
  component checkSquares = checkSquares();
  for (var row = 0; row<9; row++) {
    for (var col = 0; col<9; col++) {
      checkSquares.solution[row][col] <== solution[row][col];
    }
  }

  // check the solution matches the puzzle
  component checkSolutionMatchesPuzzle = checkSolutionMatchesPuzzle();
  for (var row = 0; row<9; row++) {
    for (var col = 0; col<9; col++) {
        checkSolutionMatchesPuzzle.puzzle[row][col] <== puzzle[row][col];
        checkSolutionMatchesPuzzle.solution[row][col] <== solution[row][col];
    }
  }

  out <== 1;
}

template checkRows() {
    signal input solution[9][9];
    component rowChecks[9];

    for (var row = 0; row < 9; row++) {
        rowChecks[row] = checkNineNumbers();
        for (var col = 0; col < 9; col++) {
            var idx = col;
            rowChecks[row].in[idx] <== solution[row][col];
        }
    }
}

template checkColumns() {
    signal input solution[9][9];
    component colChecks[9];

    for (var col = 0; col < 9; col++) {
        colChecks[col] = checkNineNumbers();
        for (var row = 0; row < 9; row++) {
            var idx = row;
            colChecks[col].in[idx] <== solution[row][col];
        }
    }
}

template checkSquares() {
    signal input solution[9][9];
    component topLeftSquare = checkNineNumbers();
    component topMiddleSquare = checkNineNumbers();
    component topRightSquare = checkNineNumbers();
    component leftMiddleSquare = checkNineNumbers();
    component middleSquare = checkNineNumbers();
    component rightMiddleSquare = checkNineNumbers();
    component bottomLeftSquare = checkNineNumbers();
    component bottomMiddleSquare = checkNineNumbers();
    component bottomRightSquare = checkNineNumbers();

    for (var rowInSquare = 0; rowInSquare < 3; rowInSquare++) {
        for (var colInSquare = 0; colInSquare < 3; colInSquare++) {
            var idx = rowInSquare * 3 + colInSquare;
            topLeftSquare.in[idx] <== solution[rowInSquare][colInSquare];
            topMiddleSquare.in[idx] <== solution[rowInSquare][colInSquare + 3];
            topRightSquare.in[idx] <== solution[rowInSquare][colInSquare + 6];

            leftMiddleSquare.in[idx] <== solution[rowInSquare+3][colInSquare];
            middleSquare.in[idx] <== solution[rowInSquare+3][colInSquare + 3];
            rightMiddleSquare.in[idx] <== solution[rowInSquare+3][colInSquare + 6];

            bottomLeftSquare.in[idx] <== solution[rowInSquare+6][colInSquare];
            bottomMiddleSquare.in[idx] <== solution[rowInSquare+6][colInSquare + 3];
            bottomRightSquare.in[idx] <== solution[rowInSquare+6][colInSquare + 6];
        }
    }
}

// Note: assumes all input values are [1,9] for the sum==45 trick to work
template checkNineNumbers() {
    signal input in[9];
    signal sum;

    // Using a bitset would be nice here, but that requires
    // writing out a version of the following using only
    // quadratic expressions:
    // 
    //   signal bitset <== 
    //     (1<<(in[0]-1));
    //     (1<<(in[1]-1)) |
    //     (1<<(in[2]-1)) |
    //     (1<<(in[3]-1)) |
    //     (1<<(in[4]-1)) |
    //     (1<<(in[5]-1)) |
    //     (1<<(in[6]-1)) |
    //     (1<<(in[7]-1)) |
    //     (1<<(in[8]-1));
    //   bitset === 511;
    //
    // Instead we just check all numbers are distinct and sum to 45 (assuming no negatives or integer overflow)

    // Confirm numbers sum to 45
    sum <== in[0] + in[1] + in[2] + in[3] + in[4] + in[5] + in[6] + in[7] + in[8];
    sum === 45;

    // Confirm no repeats
    component checkDistinct = checkAllNumbersDistinct();
    for (var i = 0; i < 9; i++) {
        checkDistinct.in[i] <== in[i];
    }
}

template checkAllNumbersDistinct() {
    signal input in[9];

    component pairsEqual[8];
    for (var pair = 0; pair < 8; pair++) {
        pairsEqual[pair] = IsEqual();
        pairsEqual[pair].in[0] <== in[pair];
        pairsEqual[pair].in[1] <== in[pair+1];
        pairsEqual[pair].out === 0;
    }
}

template checkSolutionMatchesPuzzle() {
    signal input puzzle[9][9];
    signal input solution[9][9];

    component checks[9][9];
    for (var row = 0; row < 9; row++){
        for (var col = 0; col < 9; col++) {
            checks[row][col] = ForceEqualIfEnabled();
            checks[row][col].in[0] <== puzzle[row][col];
            checks[row][col].in[1] <== solution[row][col];
            checks[row][col].enabled <== puzzle[row][col];
        }
    }
}

template checkNumbersInRange() {
    signal input solution[9][9];
    component ltChecks[9][9];
    component gtChecks[9][9];
    for (var row = 0; row < 9; row++) {
        for (var col = 0; col < 9; col++) {
            ltChecks[row][col] = LessEqThan(8); // 8 bits for our numbers
            ltChecks[row][col].in[0] <== solution[row][col];
            ltChecks[row][col].in[1] <== 9;
            ltChecks[row][col].out === 1;

            gtChecks[row][col] = GreaterThan(8); // 8 bits for our numbers
            gtChecks[row][col].in[0] <== solution[row][col];
            gtChecks[row][col].in[1] <== 0;
            gtChecks[row][col].out === 1;
        }
    }
}

component main{public [puzzle]} = Main();
