# Quick Start Guide - Windows

## Setup (One-time)

1. **Install Docker Desktop for Windows**
   - Download from: https://www.docker.com/products/docker-desktop
   - Make sure it's running before using latex-pdf-clean

2. **Install latex-pdf-clean**

   Open PowerShell in this folder and run:
   ```powershell
   .\Install-Windows.ps1
   ```

   Or use it directly from this folder without installation:
   ```powershell
   .\latex-pdf-clean.ps1 your-file.tex
   ```

## Usage

### Basic Compilation

```powershell
latex-pdf-clean.ps1 report.tex
```

### Keep the Log File

```powershell
latex-pdf-clean.ps1 -KeepLog report.tex
```

### Keep All Temporary Files

```powershell
latex-pdf-clean.ps1 -KeepAll report.tex
```

### Use from Any Folder (After Installation)

After running `Install-Windows.ps1`, you can use it from any folder:

```powershell
cd C:\Users\YourName\Documents\MyLatexProject
latex-pdf-clean.ps1 thesis.tex
```

## First-Time Note

The first time you run the script, Docker will download the LaTeX image (~2.25GB).
This is a one-time download and subsequent runs will be much faster.

## Troubleshooting

### Docker not found
- Make sure Docker Desktop is installed and running
- Restart your terminal after installing Docker

### Permission denied
- Make sure Docker Desktop has permission to access your drives
- Check Docker Desktop Settings → Resources → File Sharing

### Path too long errors
- Keep your LaTeX projects in folders with shorter paths
- Avoid deeply nested folder structures

## Alternative: Use with Git Bash

If you have Git for Windows installed, you can also use the original bash script:

```bash
./latex-pdf-clean test/sample.tex
```

## VSCode Integration

You can add this to your VSCode tasks.json to compile with a keyboard shortcut:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Compile LaTeX",
            "type": "shell",
            "command": "latex-pdf-clean.ps1",
            "args": ["${file}"],
            "problemMatcher": [],
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        }
    ]
}
```

Then press `Ctrl+Shift+B` to compile the current .tex file.
