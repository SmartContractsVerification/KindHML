# KindHML — formal verification for smart contracts

Prerequisites
- Python 3.8 or newer
- Kind 2 model checker. Ensure the Kind2 binary is available in `./kind2/kind2`.
- cvc5 SMT-solver: `pip install cvc5`

How to run (from home directory):

- `python3 src/kindHML.py <contract.sol> <property|ALL> <n_participants> <timeout>`
- Example (run Additivity property of contract Bank, 2 participants, 60s timeout):
	`python3 src/kindHML.py contracts/bank/bank.sol Additivity 2 60`

- Example (run ALL properties of contract Bank, 2 participants, 30s timeout):
	`python3 src/kindHML.py contracts/bank/bank.sol ALL 2 30`

Reproduce experiments
- To reproduce all the experiments from the paper run:
	`./run_experiments.sh`



