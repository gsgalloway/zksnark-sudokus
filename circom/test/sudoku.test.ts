import hre from "hardhat";
import { CircuitTestUtils } from "hardhat-circom";
import { assert } from "chai";

describe("sudoku circuit", () => {
  let circuit: CircuitTestUtils;

  const sampleInput = {
    x: 5,
  };
  const sanityCheck = true;

  before("setup", async () => {
    circuit = await hre.circuitTest.setup("sudoku");
  });

  it("produces a witness with valid constraints", async () => {
    const witness = await circuit.calculateWitness(sampleInput, sanityCheck);
    await circuit.checkConstraints(witness);
  });

  it("has expected witness values", async () => {
    const witness = await circuit.calculateLabeledWitness(
      sampleInput,
      sanityCheck
    );
    assert.propertyVal(witness, "main.x", "5");
    assert.propertyVal(witness, "main.x_squared", "25");
    assert.propertyVal(witness, "main.x_cubed", undefined);
    assert.propertyVal(witness, "main.out", "127");
  });

  it("has the correct output", async () => {
    const expected = { out: 127 };
    const witness = await circuit.calculateWitness(sampleInput, sanityCheck);
    await circuit.assertOut(witness, expected);
  });
});
