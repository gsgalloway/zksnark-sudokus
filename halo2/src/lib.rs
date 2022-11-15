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

#[derive(Clone, Debug)]
pub struct SudokuConfig {
    main_gate_config: MainGateConfig,
}

impl SudokuConfig {
    pub fn new<F: FieldExt>(meta: &mut ConstraintSystem<F>) -> Self {
        let main_gate_config = MainGate::configure(meta);
        SudokuConfig { main_gate_config }
    }

    fn main_gate<F: FieldExt>(&self) -> MainGate<F> {
        MainGate::<F>::new(self.main_gate_config.clone())
    }
}

#[derive(Clone, Debug, Default)]
pub struct SudokuCircuit<F: FieldExt> {
    pub board: Array2<u8>,
    pub solution: Array2<u8>,
    marker: PhantomData<F>,
}

impl<F: FieldExt> Circuit<F> for SudokuCircuit<F> {
    type Config = SudokuConfig;
    type FloorPlanner = SimpleFloorPlanner;

    fn without_witnesses(&self) -> Self {
        // TODO: is this where I assert that the boards are 9x9?
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
        layouter.assign_region(
            || "region 0",
            |region| {
                let offset = 0;
                let ctx = &mut RegionCtx::new(region, offset);

                // load the given solution (private) into the circuit
                let solution_cells = self.load_solution(&config, ctx)?;

                // check that both the rows and the columns are both valid
                // using ndarray here to abstract away the index math for slicing rows and columns
                for i in 0..9 {
                    let row = solution_cells.row(i);
                    let col = solution_cells.column(i);
                    self.check_nine_cells(&config, ctx, row)?;
                    self.check_nine_cells(&config, ctx, col)?;
                }

                // check each 3x3 square
                for row_start in [0, 3, 6] {
                    for col_start in [0, 3, 6] {
                        let row_end = row_start + 3;
                        let col_end = col_start + 3;
                        let square =
                            solution_cells.slice(s![row_start..row_end, col_start..col_end]);
                        self.check_nine_cells(&config, ctx, square)?;
                    }
                }

                // load in the board (public) and check that the solution matches

                Ok(())
            },
        )?;

        Ok(())
    }
}

impl<F: FieldExt> SudokuCircuit<F> {
    fn load_solution(
        &self,
        config: &SudokuConfig,
        ctx: &mut RegionCtx<F>,
    ) -> Result<Array2<AssignedCell<F, F>>, Error> {
        let main_gate: MainGate<F> = config.main_gate();

        let solution_cells: Array2<AssignedCell<F, F>> = self.solution.mapv(|value| {
            let value = Value::known(F::from_u128(u128::from(value)));
            main_gate.assign_value(ctx, value).unwrap()
        });

        Ok(solution_cells)
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
    use super::*;

    #[test]
    fn test_sudoku() {
        use halo2wrong::halo2::{dev::MockProver, halo2curves::bn256::Fr as Fp};

        // The number of rows in our circuit cannot exceed 2^k.
        let k = 10;

        // Instantiate the circuit with its inputs
        let circuit = SudokuCircuit {
            board: array![
                [0, 0, 0, 2, 6, 0, 7, 0, 1],
                [6, 8, 0, 0, 7, 0, 0, 9, 0],
                [1, 9, 0, 0, 0, 4, 5, 0, 0],
                [8, 2, 0, 1, 0, 0, 0, 4, 0],
                [0, 0, 4, 6, 0, 2, 9, 0, 0],
                [0, 5, 0, 0, 0, 3, 0, 2, 8],
                [0, 0, 9, 3, 0, 0, 0, 7, 4],
                [0, 4, 0, 0, 5, 0, 0, 3, 6],
                [7, 0, 3, 0, 1, 8, 0, 0, 0],
            ],
            solution: array![
                [4, 3, 5, 2, 6, 9, 7, 8, 1],
                [6, 8, 2, 5, 7, 1, 4, 9, 3],
                [1, 9, 7, 8, 3, 4, 5, 6, 2],
                [8, 2, 6, 1, 9, 5, 3, 4, 7],
                [3, 7, 4, 6, 8, 2, 9, 1, 5],
                [9, 5, 1, 7, 4, 3, 6, 2, 8],
                [5, 1, 9, 3, 2, 6, 8, 7, 4],
                [2, 4, 8, 9, 5, 7, 1, 3, 6],
                [7, 6, 3, 4, 1, 8, 2, 5, 9],
            ],
            marker: PhantomData,
        };

        use plotters::prelude::*;
        let drawing_area = BitMapBackend::new("layout.png", (1024, 768)).into_drawing_area();
        drawing_area.fill(&WHITE).unwrap();
        let drawing_area = drawing_area
            .titled("Sudoku Circuit", ("sans-serif", 60))
            .unwrap();

        halo2wrong::halo2::dev::CircuitLayout::default()
            // You can optionally render only a section of the circuit.
            // .view_width(0..10)
            // .view_height(0..16)
            // You can hide labels, which can be useful with smaller areas.
            .show_labels(true)
            .mark_equality_cells(true)
            .show_equality_constraints(true)
            // Render the circuit onto your area!
            // The first argument is the size parameter for the circuit.
            .render(5, &circuit, &drawing_area)
            .unwrap();

        // Arrange the public input. We expose the multiplication result in row 0
        // of the instance column, so we position it there in our public inputs.
        let mut public_inputs: Vec<Fp> = circuit
            .board
            .mapv(|value| Fp::from_u128(u128::from(value)))
            .into_raw_vec();
        let mut public_inputs = vec![public_inputs];

        // Given the correct public input, our circuit will verify.
        let prover = MockProver::run(k, &circuit, public_inputs).unwrap();
        assert_eq!(prover.verify(), Ok(()));

        // If we try some other public input, the proof will fail!
        // public_inputs[0] += Fp::one();
        // let prover = MockProver::run(k, &circuit, vec![public_inputs]).unwrap();
        // assert!(prover.verify().is_err());
    }
}
