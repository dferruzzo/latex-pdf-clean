# latex-pdf-clean

Small Bash utility to compile a single `.tex` file to PDF using Docker (latest TeX Live) and then remove common LaTeX temporary files.

## Requirements

### Linux/macOS
- `bash`
- `docker` available in `PATH`
- A local `.tex` file
- Docker access to pull `dferruzzo/latex:latest` from Docker Hub

### Windows
- PowerShell 5.1 or later (built into Windows 10/11)
- Docker Desktop for Windows
- A local `.tex` file
- Docker access to pull `dferruzzo/latex:latest` from Docker Hub

## Install on Linux/macOS (after cloning)

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

## Install on Windows (after cloning)

### Automatic Installation (Recommended)

From the project folder in PowerShell:

```powershell
.\Install-Windows.ps1
```

This will:
- Install `latex-pdf-clean.ps1` to `$HOME\bin`
- Add it to your PATH automatically
- Verify Docker is installed

After installation, restart your terminal and run from anywhere:

```powershell
latex-pdf-clean.ps1 your-file.tex
```

### Manual Installation

1. Copy `latex-pdf-clean.ps1` to a directory in your PATH (e.g., `C:\Users\YourName\bin`)
2. Add that directory to your PATH if needed
3. Run from anywhere: `latex-pdf-clean.ps1 your-file.tex`

### Alternative: Use from project folder

Without installation, run from the project folder:

```powershell
.\latex-pdf-clean.ps1 your-file.tex
```

## Dockerfile note

The script runs the published image `dferruzzo/latex:latest` by default, so `Dockerfile` is not required for day-to-day use.
Keep `Dockerfile` if you want to rebuild, customize, or republish the image.

## Usage

### Linux/macOS

```bash
./latex-pdf-clean [-log] [-keep] <file.tex>
```

### Windows (PowerShell)

```powershell
latex-pdf-clean.ps1 [-KeepLog] [-KeepAll] <file.tex>
```

Default Docker image: `dferruzzo/latex:latest`.
You can override it with the `LATEX_IMAGE` environment variable.

### Options

**Linux/macOS:**
- `-log`: keep the generated `.log` file
- `-keep`: keep all generated files (skip cleanup after compile)

**Windows (PowerShell):**
- `-KeepLog`: keep the generated `.log` file
- `-KeepAll`: keep all generated files (skip cleanup after compile)

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

### Linux/macOS

Compile and remove log:

```bash
./latex-pdf-clean report.tex
```

Compile and keep log:

```bash
./latex-pdf-clean -log report.tex
```

Keep all files:

```bash
./latex-pdf-clean -keep report.tex
```

### Windows (PowerShell)

Compile and remove log:

```powershell
latex-pdf-clean.ps1 report.tex
```

Compile and keep log:

```powershell
latex-pdf-clean.ps1 -KeepLog report.tex
```

Keep all files:

```powershell
latex-pdf-clean.ps1 -KeepAll report.tex
```

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
