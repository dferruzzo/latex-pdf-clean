# latex-pdf-clean

Small Bash utility to compile a single `.tex` file to PDF using Docker (latest TeX Live) and then remove common LaTeX temporary files.

## Requirements

- `bash`
- `docker` available in `PATH`
- A local `.tex` file
- Docker access to pull `dferruzzo/latex:latest` from Docker Hub

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

## Dockerfile note

The script runs the published image `dferruzzo/latex:latest` by default, so `Dockerfile` is not required for day-to-day use.
Keep `Dockerfile` if you want to rebuild, customize, or republish the image.

## Usage

```bash
./latex-pdf-clean [-log] [-keep] <file.tex>
```

Default Docker image: `dferruzzo/latex:latest`.
You can override it with the `LATEX_IMAGE` environment variable.

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
	docker run --rm --user "$(id -u):$(id -g)" -v "<tex_dir>:/data" --entrypoint latexmk dferruzzo/latex:latest -pdf <file.tex>
	```

	If the image is not present locally, Docker will pull it automatically.
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

Compile with a custom image tag:

```bash
LATEX_IMAGE=dferruzzo/latex:v1 ./latex-pdf-clean report.tex
```

## Error cases

The script exits with error when:

- no input file is provided
- more than one file is provided
- input is not a `.tex` file
- file does not exist
- unknown option is passed
- `docker` is not available
