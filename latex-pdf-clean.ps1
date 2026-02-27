#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Compile LaTeX files to PDF using Docker, then clean up intermediate files

.DESCRIPTION
    This script compiles a .tex file to PDF using Docker (TeX Live) and removes
    common LaTeX temporary files after compilation.

.PARAMETER TexFile
    The .tex file to compile

.PARAMETER KeepLog
    Keep the generated .log file

.PARAMETER KeepAll
    Keep all generated files (skip cleanup after compile)

.PARAMETER Image
    Docker image to use (default: dferruzzo/latex:latest)

.EXAMPLE
    latex-pdf-clean.ps1 report.tex

.EXAMPLE
    latex-pdf-clean.ps1 -KeepLog report.tex

.EXAMPLE
    latex-pdf-clean.ps1 -KeepAll -TexFile report.tex
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "The .tex file to compile")]
    [string]$TexFile,

    [Parameter(HelpMessage = "Keep the generated .log file")]
    [switch]$KeepLog,

    [Parameter(HelpMessage = "Keep all generated files (skip cleanup)")]
    [switch]$KeepAll,

    [Parameter(HelpMessage = "Docker image to use")]
    [string]$Image = $env:LATEX_IMAGE ?? "dferruzzo/latex:latest"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Validate that the file exists
if (-not (Test-Path -Path $TexFile -PathType Leaf)) {
    Write-Error "Error: file not found: $TexFile"
    exit 1
}

# Get absolute path and validate extension
$texFileItem = Get-Item -Path $TexFile
if ($texFileItem.Extension -ne ".tex") {
    Write-Error "Error: argument must be a .tex file (got: $($texFileItem.Extension))"
    exit 1
}

# Extract directory and filename information
$texAbsDir = $texFileItem.DirectoryName
$texFileName = $texFileItem.Name
$texBaseName = $texFileItem.BaseName

Write-Host "TeX file: $texFileName" -ForegroundColor Cyan
Write-Host "TeX directory: $texAbsDir" -ForegroundColor Cyan
Write-Host "Output name: $texBaseName" -ForegroundColor Cyan
Write-Host "Docker image: $Image" -ForegroundColor Cyan
Write-Host ""

# Check that Docker is available
try {
    $null = Get-Command docker -ErrorAction Stop
} catch {
    Write-Error "Error: docker is not available in PATH. Please install Docker Desktop for Windows."
    exit 1
}

# Convert Windows path to Docker-compatible format
# Docker Desktop on Windows handles path conversion, but we need forward slashes
$dockerPath = $texAbsDir -replace '\\', '/'

# If it's a drive letter path (C:), convert to //c/ format for Docker
if ($dockerPath -match '^([A-Za-z]):(.*)$') {
    $drive = $matches[1].ToLower()
    $path = $matches[2]
    $dockerPath = "/$drive$path"
}

Write-Host "Compiling LaTeX document..." -ForegroundColor Yellow

# Compile the .tex file inside Docker container
# Note: Docker Desktop on Windows handles user permissions differently than Linux
try {
    docker run --rm `
        -v "${texAbsDir}:/data" `
        --entrypoint latexmk `
        $Image `
        -pdf `
        -interaction=nonstopmode `
        -file-line-error `
        $texFileName

    if ($LASTEXITCODE -ne 0) {
        Write-Error "LaTeX compilation failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "Docker execution failed: $_"
    exit 1
}

# Clean up intermediate files (unless -KeepAll was specified)
if (-not $KeepAll) {
    Write-Host "Cleaning up intermediate files..." -ForegroundColor Yellow
    
    # Remove LaTeX auxiliary files
    $filesToRemove = @(
        "$texAbsDir\*.aux",
        "$texAbsDir\$texBaseName.nlo",
        "$texAbsDir\$texBaseName.dvi",
        "$texAbsDir\$texBaseName.nav",
        "$texAbsDir\$texBaseName.out",
        "$texAbsDir\$texBaseName.snm",
        "$texAbsDir\$texBaseName.toc",
        "$texAbsDir\$texBaseName.vrb",
        "$texAbsDir\$texBaseName.fls",
        "$texAbsDir\$texBaseName.fdb_latexmk",
        "$texAbsDir\$texBaseName.synctex.gz",
        "$texAbsDir\$texBaseName.bbl",
        "$texAbsDir\$texBaseName.blg",
        "$texAbsDir\$texBaseName.bcf",
        "$texAbsDir\$texBaseName.run.xml"
    )
    
    foreach ($pattern in $filesToRemove) {
        if (Test-Path $pattern) {
            Remove-Item $pattern -Force -ErrorAction SilentlyContinue
        }
    }
}

# Output the result
Write-Host ""
Write-Host "Compilation complete!" -ForegroundColor Green

$pdfPath = Join-Path $texAbsDir "$texBaseName.pdf"
$logPath = Join-Path $texAbsDir "$texBaseName.log"

if ($KeepLog) {
    # Output both PDF and log file paths
    Write-Host "PDF: $pdfPath" -ForegroundColor Green
    Write-Host "Log: $logPath" -ForegroundColor Green
} else {
    # Remove log file unless -KeepAll was specified
    if (-not $KeepAll -and (Test-Path $logPath)) {
        Remove-Item $logPath -Force -ErrorAction SilentlyContinue
    }
    
    # Output PDF file path
    Write-Host "PDF: $pdfPath" -ForegroundColor Green
}
