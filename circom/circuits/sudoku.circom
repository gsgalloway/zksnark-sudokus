pragma circom 2.1.0;

template Main() {
  signal input puzzle[9, 9];
  signal input solution[9, 9];
  signal x <-- puzzle[0, 0];
  signal x_squared;
  signal x_cubed;
  signal output out;

  component checkRows = checkRows();
  for (var i = 0; i<81; i++) {
        checkRows.solution[i] <== solution[i];
  }

  x_squared <== x * x;
  x_cubed <== x_squared * x;
//   out <== checkNineNumbers(1, 2, 3, 4, 5, 6, 7, 8, 9);
  out <== 1;
}

template checkRows() {
    signal input solution[81];
    signal multiplesOfNine[3];
    multiplesOfNine[0] <== 9*0;
    multiplesOfNine[1] <== 9*1;
    multiplesOfNine[2] <== 9*2;
    // component checkRow1 = checkNineNumbers();
    // component checkRow2 = checkNineNumbers();
    // component checkRow3 = checkNineNumbers();
    for (var row = 0; row < 9; row++) {
        var rowValid = checkNineNumbers(
            solution[row*9 + 0],
            solution[row*9 + 1],
            solution[row*9 + 2],
            solution[row*9 + 3],
            solution[row*9 + 4],
            solution[row*9 + 5],
            solution[row*9 + 6],
            solution[row*9 + 7],
            solution[row*9 + 8]
        );
        rowsValid[row] <== rowValid;
    }
}

template checkRow() {
    signal input row[9];
    signal rowValid;

    rowValid <== checkNineNumbers(
        row[0],
        row[1],
        row[2],
        row[3],
        row[4],
        row[5],
        row[6],
        row[7],
        row[8]
    );
    rowValid === 1;
}

function checkNineNumbers(n1, n2, n3, n4, n5, n6, n7, n8, n9) {
  var bitmap = 
    (1 << (n1-1)) |
    (1 << (n2-1)) |
    (1 << (n3-1)) |
    (1 << (n4-1)) |
    (1 << (n5-1)) |
    (1 << (n6-1)) |
    (1 << (n7-1)) |
    (1 << (n8-1)) |
    (1 << (n9-1));
  // The full bitmap, 0b111111111 == 511
  return bitmap == 511;
}

component main{public [puzzle]} = Main();
