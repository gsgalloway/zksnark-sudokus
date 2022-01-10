build:
	cairo-compile './contracts/main.cairo' --output './contracts/main_compiled.json'

program-hash: build
	cairo-hash-program --program ./contracts/main_compiled.json

run: build
	cairo-run --program='./contracts/main_compiled.json' --layout=small --print_output
