// use maingate::{MainGate, MainGateConfig};
use halo2wrong::halo2::{
    arithmetic::FieldExt,
    circuit::{AssignedCell, Chip, Layouter, Region, SimpleFloorPlanner, Value},
    // dev::circuit_dot_graph,
    plonk::{Advice, Circuit, Column, ConstraintSystem, Error, Fixed, Instance, Selector},
    poly::Rotation,
};
use maingate::{MainGate, MainGateConfig};
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
    pub board: [[u8; 9]; 9],
    pub solution: [[u8; 9]; 9],
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

        layouter.assign_region(|| "region 0", |region| Ok(()));

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_sudoku() {
        use halo2wrong::halo2::{dev::MockProver, halo2curves::bn256::Fr as Fp};

        // ANCHOR: test-circuit
        // The number of rows in our circuit cannot exceed 2^k. Since our example
        // circuit is very small, we can pick a very small value here.
        let k = 4;

        // Prepare the private and public inputs to the circuit!
        let constant = Fp::from(7);
        let a = Fp::from(2);
        let b = Fp::from(3);
        let c = constant * a.square() * b.square();

        // Instantiate the circuit with the private inputs.
        let circuit = SudokuCircuit {
            board: [
                [7, 6, 9, 5, 3, 8, 1, 2, 4],
                [2, 4, 3, 7, 1, 9, 6, 5, 8],
                [8, 5, 1, 4, 6, 2, 9, 7, 3],
                [4, 8, 6, 9, 7, 5, 3, 1, 2],
                [5, 3, 7, 6, 2, 1, 4, 8, 9],
                [1, 9, 2, 8, 4, 3, 7, 6, 5],
                [6, 1, 8, 3, 5, 4, 2, 9, 7],
                [9, 7, 4, 2, 8, 6, 5, 3, 1],
                [3, 2, 5, 1, 9, 7, 8, 4, 6],
            ],
            solution: [
                [7, 6, 9, 5, 3, 8, 1, 2, 4],
                [2, 4, 3, 7, 1, 9, 6, 5, 8],
                [8, 5, 1, 4, 6, 2, 9, 7, 3],
                [4, 8, 6, 9, 7, 5, 3, 1, 2],
                [5, 3, 7, 6, 2, 1, 4, 8, 9],
                [1, 9, 2, 8, 4, 3, 7, 6, 5],
                [6, 1, 8, 3, 5, 4, 2, 9, 7],
                [9, 7, 4, 2, 8, 6, 5, 3, 1],
                [3, 2, 5, 1, 9, 7, 8, 4, 6],
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
        let mut public_inputs = vec![c];

        // Given the correct public input, our circuit will verify.
        let prover = MockProver::run(k, &circuit, vec![public_inputs.clone()]).unwrap();
        assert_eq!(prover.verify(), Ok(()));

        // If we try some other public input, the proof will fail!
        public_inputs[0] += Fp::one();
        let prover = MockProver::run(k, &circuit, vec![public_inputs]).unwrap();
        // assert!(prover.verify().is_err());
    }
}
