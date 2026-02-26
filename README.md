# latex-pdf-clean

Small Bash utility to compile a single `.tex` file to PDF using Docker (`blang/latex`) and then remove common LaTeX temporary files.

## Requirements

- `bash`
- `docker` available in `PATH`
- A local `.tex` file
- Docker image: `blang/latex` (pulled automatically by Docker if needed)

## Usage

```bash
./latex-pdf-clean [-log] <file.tex>
```

### Options

- `-log`: keep the generated `.log` file

## What it does

1. Validates arguments:
	- accepts at most one `.tex` file
	- rejects unknown options
2. Verifies the input file exists and has `.tex` extension.
3. Verifies `docker` is installed.
4. Runs:

	```bash
	docker run --rm -v "<tex_dir>:/data" blang/latex pdflatex "<file.tex>"
	```

5. Removes common auxiliary files:

	- `.aux`, `.nav`, `.out`, `.snm`, `.toc`, `.vrb`
	- `.fls`, `.fdb_latexmk`, `.synctex.gz`
	- `.bbl`, `.blg`, `.bcf`, `.run.xml`
	- `.log` (unless `-log` is used)

## Output

- Always prints the full path to the generated PDF.
- If `-log` is used, also prints the full path to the `.log` file.

## Examples

Compile and remove log:

```bash
./latex-pdf-clean report.tex
```

Compile and keep log:

```bash
./latex-pdf-clean -log report.tex
```

## Error cases

The script exits with error when:

- no input file is provided
- more than one file is provided
- input is not a `.tex` file
- file does not exist
- unknown option is passed
- `docker` is not available
