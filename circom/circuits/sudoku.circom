pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
  signal input puzzle[81];
  signal input solution[81];
  signal x <-- puzzle[0];
  signal x_squared;
  signal x_cubed;
  signal output out;

  // Check all values less than 10
  component checkInRange = checkNumbersInRange();
  for (var i = 0; i<81; i++) {
    checkInRange.solution[i] <== solution[i];
  }

  // check the rows
  component checkRows = checkRows();
  for (var i = 0; i<81; i++) {
    checkRows.solution[i] <== solution[i];
  }

  // check the columns
  component checkCols = checkColumns();
  for (var i = 0; i<81; i++) {
    checkCols.solution[i] <== solution[i];
  }

  // check the squares
  component checkSquares = checkSquares();
  for (var i = 0; i<81; i++) {
    checkSquares.solution[i] <== solution[i];
  }

  // check the solution matches the puzzle
  component checkSolutionMatchesPuzzle = checkSolutionMatchesPuzzle();
  for (var i = 0; i < 81; i++) {
    checkSolutionMatchesPuzzle.puzzle[i] <== puzzle[i];
    checkSolutionMatchesPuzzle.solution[i] <== solution[i];
  }

  x_squared <== x * x;
  x_cubed <== x_squared * x;
//   out <== checkNineNumbers(1, 2, 3, 4, 5, 6, 7, 8, 9);
  out <== 1;
}

template checkRows() {
    signal input solution[81];
    component rowChecks[9];

    for (var row = 0; row < 9; row++) {
        rowChecks[row] = checkNineNumbers();
        for (var col = 0; col < 9; col++) {
            var idx = col;
            rowChecks[row].in[idx] <== solution[9*row + col];
        }
    }
}

template checkColumns() {
    signal input solution[81];
    component colChecks[9];

    for (var col = 0; col < 9; col++) {
        colChecks[col] = checkNineNumbers();
        for (var row = 0; row < 9; row++) {
            var idx = row;
            colChecks[col].in[idx] <== solution[9*row + col];
        }
    }
}

template checkSquares() {
    signal input solution[81];
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
            topLeftSquare.in[idx] <== solution[rowInSquare*9 + colInSquare];
            topMiddleSquare.in[idx] <== solution[rowInSquare*9 + colInSquare + 3];
            topRightSquare.in[idx] <== solution[rowInSquare*9 + colInSquare + 6];

            leftMiddleSquare.in[idx] <== solution[(rowInSquare+3)*9 + colInSquare];
            middleSquare.in[idx] <== solution[(rowInSquare+3)*9 + colInSquare + 3];
            rightMiddleSquare.in[idx] <== solution[(rowInSquare+3)*9 + colInSquare + 6];

            bottomLeftSquare.in[idx] <== solution[(rowInSquare+6)*9 + colInSquare];
            bottomMiddleSquare.in[idx] <== solution[(rowInSquare+6)*9 + colInSquare + 3];
            bottomRightSquare.in[idx] <== solution[(rowInSquare+6)*9 + colInSquare + 6];
        }
    }
}

// Note: assumes all input values are < 10, or else we risk overflow from addition
template checkNineNumbers() {
    signal input in[9];
    signal sum;

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

    // Using a bitset would be nice here, but that requires
    // writing out a version of the following using only
    // quadratic expressions:
    // 
    // signal bitset <== 
    //   (1<<(in[0]-1));
    //   (1<<(in[1]-1)) |
    //   (1<<(in[2]-1)) |
    //   (1<<(in[3]-1)) |
    //   (1<<(in[4]-1)) |
    //   (1<<(in[5]-1)) |
    //   (1<<(in[6]-1)) |
    //   (1<<(in[7]-1)) |
    //   (1<<(in[8]-1));
    // bitset === 511;

    component pairsEqual[8];
    for (var pair = 0; pair < 8; pair++) {
        pairsEqual[pair] = IsEqual();
        pairsEqual[pair].in[0] <== in[pair];
        pairsEqual[pair].in[1] <== in[pair+1];
        pairsEqual[pair].out === 0;
    }
}

template checkSolutionMatchesPuzzle() {
    signal input puzzle[81];
    signal input solution[81];

    component checks[81];
    for (var i = 0; i < 81; i++){
        checks[i] = ForceEqualIfEnabled();
        checks[i].in[0] <== puzzle[i];
        checks[i].in[1] <== solution[i];
        checks[i].enabled <== puzzle[i];
    }
}

template checkNumbersInRange() {
    signal input solution[81];
    component ltChecks[81];
    for (var i = 0; i < 81; i++) {
        ltChecks[i] = LessEqThan(8); // 8 bits for our numbers
        ltChecks[i].in[0] <== solution[i];
        ltChecks[i].in[1] <== 9;
        ltChecks[i].out === 1;
    }
}

component main{public [puzzle]} = Main();
