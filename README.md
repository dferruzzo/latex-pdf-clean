# latex-pdf-clean

Small Bash utility to compile a single `.tex` file to PDF using Docker (latest TeX Live) and then remove common LaTeX temporary files.

## Requirements

- `bash`
- `docker` available in `PATH`
- A local `.tex` file
- Docker (latest TeX Live image will be built automatically on first run)

## Install on Linux (after cloning)

From the project folder:

```bash
chmod +x latex-pdf-clean
```

### Option 1: use it from this folder

Run with:

```bash
./latex-pdf-clean your-file.tex
```

### Option 2: install system-wide

```bash
sudo install -m 755 latex-pdf-clean /usr/local/bin/latex-pdf-clean
```

Then run from anywhere:

```bash
latex-pdf-clean your-file.tex
```

If Docker needs `sudo` on your machine, either run with `sudo` or add your user to the `docker` group.

## Usage

```bash
./latex-pdf-clean [-log] [-keep] <file.tex>
```

### Options

- `-log`: keep the generated `.log` file
- `-keep`: keep all generated files (skip cleanup after compile)

## What it does

1. Validates arguments:
	- accepts at most one `.tex` file
	- rejects unknown options
2. Verifies the input file exists and has `.tex` extension.
3. Verifies `docker` is installed.
4. Runs `latexmk` in Docker (with your host user UID/GID), for example:

	```bash
	docker run --rm --user "$(id -u):$(id -g)" -v "<tex_dir>:/data" --entrypoint latexmk latex-pdf-clean:latest -pdf <file.tex>
	```

	This ensures generated files are owned by your user (not `root`) and bibliography/cross-references are resolved automatically.

5. Removes common auxiliary files:

	- `.aux`, `.nav`, `.out`, `.snm`, `.toc`, `.vrb`
	- `.fls`, `.fdb_latexmk`, `.synctex.gz`
	- `.bbl`, `.blg`, `.bcf`, `.run.xml`
	- `.log` (unless `-log` is used)

   If `-keep` is used, no files are removed.

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

Compile and keep all generated files:

```bash
./latex-pdf-clean -keep report.tex
```

## Error cases

The script exits with error when:

- no input file is provided
- more than one file is provided
- input is not a `.tex` file
- file does not exist
- unknown option is passed
- `docker` is not available
