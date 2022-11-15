use halo2::plonk::{Column, Instance};
use halo2wrong::{
    halo2::{
        arithmetic::FieldExt,
        circuit::{AssignedCell, Layouter, SimpleFloorPlanner, Value},
        plonk::{Circuit, ConstraintSystem, Error},
    },
    RegionCtx,
};
use itertools::Itertools;
use maingate::{MainGate, MainGateConfig, MainGateInstructions, Term};
use ndarray::prelude::*;
use std::marker::PhantomData;

// SudokuConfig defines the columns we will use directly in our circuit,
// as well as the configurations for all gadgets we will use. In this case,
// we use the `maingate` gadget which is a convenience wrapper on top of the
// standard PLONK gate and includes instructions for common primitives like `add`
#[derive(Clone, Debug)]
pub struct SudokuConfig {
    main_gate_config: MainGateConfig,
    public_input_puzzle: Column<Instance>,
}

impl SudokuConfig {
    pub fn new<F: FieldExt>(meta: &mut ConstraintSystem<F>) -> Self {
        let main_gate_config = MainGate::configure(meta);
        let puzzle = meta.instance_column();
        meta.enable_equality(puzzle);
        SudokuConfig {
            main_gate_config,
            public_input_puzzle: puzzle,
        }
    }

    fn main_gate<F: FieldExt>(&self) -> MainGate<F> {
        MainGate::<F>::new(self.main_gate_config.clone())
    }
}

// SudokuCircuit is responsible for initializing its config (and all gadgets registered therein)
// as well as defining all the constraints for the table (i.e. constructing the circuit)
#[derive(Clone, Debug, Default)]
pub struct SudokuCircuit<F: FieldExt> {
    pub puzzle: Array2<u8>,
    pub solution: Array2<u8>,
    marker: PhantomData<F>,
}

impl<F: FieldExt> Circuit<F> for SudokuCircuit<F> {
    type Config = SudokuConfig;
    type FloorPlanner = SimpleFloorPlanner;

    fn without_witnesses(&self) -> Self {
        Self::default()
    }

    fn configure(meta: &mut ConstraintSystem<F>) -> Self::Config {
        SudokuConfig::new(meta)
    }

    fn synthesize(
        &self,
        config: Self::Config,
        mut layouter: impl Layouter<F>,
    ) -> Result<(), Error> {
        let main_gate: MainGate<F> = config.main_gate();
        let mut board_cells: Array2<AssignedCell<F, F>> = array![[]];

        layouter.assign_region(
            || "region 0",
            |region| {
                let offset = 0;
                let ctx = &mut RegionCtx::new(region, offset);

                // Load the puzzle (public) into the circuit.
                // Note that this is loaded into advice columns as is the `solution`.
                // Later we will compare all cells for the `board` against all cells
                // in our public_input column to effectively expose this as a public input.
                board_cells = self.load_board(&config, ctx, &self.puzzle)?;

                // load the solution (private) into the circuit
                let solution_cells = self.load_board(&config, ctx, &self.solution)?;

                // check that both the rows and the columns are both valid
                // using ndarray here to abstract away the index math for slicing rows and columns
                for i in 0..9 {
                    let row = solution_cells.row(i);
                    let col = solution_cells.column(i);
                    self.check_nine_cells(&config, ctx, row)?;
                    self.check_nine_cells(&config, ctx, col)?;
                }

                // check each 3x3 square
                for sq_start_row in [0, 3, 6] {
                    for sq_start_col in [0, 3, 6] {
                        let sq_end_row = sq_start_row + 3;
                        let sq_end_col = sq_start_col + 3;
                        let square = solution_cells
                            .slice(s![sq_start_row..sq_end_row, sq_start_col..sq_end_col]);
                        self.check_nine_cells(&config, ctx, square)?;
                    }
                }

                // check that the solution matches the board
                // check each cell in `board` is either zero or equals the corresponding cell in `solution`
                for row_idx in 0..9 {
                    for col_idx in 0..9 {
                        let board_cell = &board_cells[[row_idx, col_idx]];
                        let solution_cell = &solution_cells[[row_idx, col_idx]];
                        let board_cell_is_zero = main_gate.is_zero(ctx, &board_cell)?;
                        let board_cell_equals_solution =
                            main_gate.is_equal(ctx, board_cell, solution_cell)?;
                        main_gate.one_or_one(
                            ctx,
                            &board_cell_is_zero,
                            &board_cell_equals_solution,
                        )?;
                    }
                }
                Ok(())
            },
        )?;

        // mark each cell of the puzzle as public input
        for (public_input_idx, assigned_value) in board_cells.iter().enumerate() {
            layouter.constrain_instance(
                assigned_value.cell(),
                config.public_input_puzzle,
                public_input_idx,
            )?;
        }

        Ok(())
    }
}

impl<F: FieldExt> SudokuCircuit<F> {
    fn load_board(
        &self,
        config: &SudokuConfig,
        ctx: &mut RegionCtx<F>,
        board: &Array2<u8>,
    ) -> Result<Array2<AssignedCell<F, F>>, Error> {
        let main_gate: MainGate<F> = config.main_gate();

        let loaded_cells: Array2<AssignedCell<F, F>> = board.mapv(|value| {
            let value = Value::known(F::from_u128(u128::from(value)));
            main_gate.assign_value(ctx, value).unwrap()
        });

        Ok(loaded_cells)
    }

    fn check_nine_cells<'a, I>(
        &self,
        config: &SudokuConfig,
        ctx: &mut RegionCtx<F>,
        cells: I,
    ) -> Result<(), Error>
    where
        I: IntoIterator<Item = &'a AssignedCell<F, F>>,
    {
        let main_gate: MainGate<F> = config.main_gate();

        let cells: Vec<&AssignedCell<F, F>> = cells.into_iter().collect();

        // Check sum of cells == 45
        // Do this by checking that the sum of the cells plus (-45) equals zero
        let expected_sum = F::from(45);
        let terms: Vec<Term<F>> = cells.iter().cloned().map(Term::assigned_to_add).collect();
        main_gate.assert_zero_sum(ctx, &terms, expected_sum.neg())?;

        // Now check that all cells are unique by asserting each adjacent pair is non-equal
        for (cell_a, cell_b) in cells.into_iter().tuple_windows() {
            main_gate.assert_not_equal(ctx, &cell_a, &cell_b)?;
        }

        Ok(())
    }
}
#[cfg(test)]
mod test {
    use halo2::dev::VerifyFailure;

    use super::*;

    fn prove_and_verify_circuit(
        puzzle: Array2<u8>,
        solution: Array2<u8>,
    ) -> Result<(), Vec<VerifyFailure>> {
        use halo2wrong::halo2::{dev::MockProver, halo2curves::bn256::Fr as Fp};

        // The number of rows in our circuit cannot exceed 2^k.
        let k = 11;

        // Instantiate the circuit with its inputs
        let circuit = SudokuCircuit {
            puzzle,
            solution,
            marker: PhantomData,
        };

        // Arrange the public inputs.
        // `maingate` registers its own Instance column which we are not using, so that column's
        // inputs can be skipped.
        // The puzzle is loaded into our own column
        let public_input_maingate = vec![];
        let public_input_puzzle: Vec<Fp> = circuit
            .puzzle
            .mapv(|value| Fp::from_u128(u128::from(value)))
            .into_raw_vec();

        let public_inputs = vec![public_input_maingate, public_input_puzzle];

        // Run prover and return result of attempting to verify
        let prover = MockProver::run(k, &circuit, public_inputs).unwrap();

        prover.verify()
    }

    #[test]
    fn test_happy_path() {
        let puzzle = array![
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ];
        let solution = array![
            [4, 3, 5, 2, 6, 9, 7, 8, 1],
            [6, 8, 2, 5, 7, 1, 4, 9, 3],
            [1, 9, 7, 8, 3, 4, 5, 6, 2],
            [8, 2, 6, 1, 9, 5, 3, 4, 7],
            [3, 7, 4, 6, 8, 2, 9, 1, 5],
            [9, 5, 1, 7, 4, 3, 6, 2, 8],
            [5, 1, 9, 3, 2, 6, 8, 7, 4],
            [2, 4, 8, 9, 5, 7, 1, 3, 6],
            [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ];
        let result = prove_and_verify_circuit(puzzle, solution);
        assert_eq!(result, Ok(()));
    }

    #[test]
    fn test_incorrect_solution() {
        let puzzle = array![
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ];
        let solution = array![
            [1, 3, 5, 2, 6, 9, 7, 8, 1], // top-left cell changed from 4 to 1
            [6, 8, 2, 5, 7, 1, 4, 9, 3],
            [1, 9, 7, 8, 3, 4, 5, 6, 2],
            [8, 2, 6, 1, 9, 5, 3, 4, 7],
            [3, 7, 4, 6, 8, 2, 9, 1, 5],
            [9, 5, 1, 7, 4, 3, 6, 2, 8],
            [5, 1, 9, 3, 2, 6, 8, 7, 4],
            [2, 4, 8, 9, 5, 7, 1, 3, 6],
            [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ];
        let result = prove_and_verify_circuit(puzzle, solution);
        assert!(result.is_err());
    }

    #[test]
    fn test_solution_cell_out_of_range() {
        let puzzle = array![
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ];
        let solution = array![
            [10, 3, 5, 2, 6, 9, 7, 8, 1],
            [6, 8, 2, 5, 7, 1, 4, 9, 3],
            [1, 9, 7, 8, 3, 4, 5, 6, 2],
            [8, 2, 6, 1, 9, 5, 3, 4, 7],
            [3, 7, 4, 6, 8, 2, 9, 1, 5],
            [9, 5, 1, 7, 4, 3, 6, 2, 8],
            [5, 1, 9, 3, 2, 6, 8, 7, 4],
            [2, 4, 8, 9, 5, 7, 1, 3, 6],
            [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ];
        let result = prove_and_verify_circuit(puzzle, solution);
        assert!(result.is_err());
    }

    #[test]
    #[should_panic]
    fn test_solution_wrong_shape() {
        let puzzle = array![
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ];
        let solution = array![
            [1, 3, 5, 2, 6, 9, 7, 8, 1],
            [6, 8, 2, 5, 7, 1, 4, 9, 3],
            [1, 9, 7, 8, 3, 4, 5, 6, 2],
            [8, 2, 6, 1, 9, 5, 3, 4, 7],
        ];
        let result = prove_and_verify_circuit(puzzle, solution);
        assert!(result.is_err());
    }

    #[test]
    fn test_valid_solution_but_wrong_public_input() {
        use halo2wrong::halo2::{dev::MockProver, halo2curves::bn256::Fr as Fp};
        let puzzle = array![
            [0, 0, 0, 2, 6, 0, 7, 0, 1],
            [6, 8, 0, 0, 7, 0, 0, 9, 0],
            [1, 9, 0, 0, 0, 4, 5, 0, 0],
            [8, 2, 0, 1, 0, 0, 0, 4, 0],
            [0, 0, 4, 6, 0, 2, 9, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 2, 8],
            [0, 0, 9, 3, 0, 0, 0, 7, 4],
            [0, 4, 0, 0, 5, 0, 0, 3, 6],
            [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ];
        let solution = array![
            [4, 3, 5, 2, 6, 9, 7, 8, 1],
            [6, 8, 2, 5, 7, 1, 4, 9, 3],
            [1, 9, 7, 8, 3, 4, 5, 6, 2],
            [8, 2, 6, 1, 9, 5, 3, 4, 7],
            [3, 7, 4, 6, 8, 2, 9, 1, 5],
            [9, 5, 1, 7, 4, 3, 6, 2, 8],
            [5, 1, 9, 3, 2, 6, 8, 7, 4],
            [2, 4, 8, 9, 5, 7, 1, 3, 6],
            [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ];
        let k = 11;
        let circuit = SudokuCircuit {
            puzzle,
            solution,
            marker: PhantomData,
        };
        // Arrange the public inputs (correctly)
        let public_input_maingate = vec![];
        let mut public_input_puzzle: Vec<Fp> = circuit
            .puzzle
            .mapv(|value| Fp::from_u128(u128::from(value)))
            .into_raw_vec();

        // Now reverse the order of elements of the public input
        public_input_puzzle.reverse();

        // Prove as normal
        let public_inputs = vec![public_input_maingate, public_input_puzzle];
        let prover = MockProver::run(k, &circuit, public_inputs).unwrap();
        assert!(prover.verify().is_err());
    }
}
