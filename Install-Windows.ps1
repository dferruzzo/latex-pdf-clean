#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install latex-pdf-clean for Windows system-wide

.DESCRIPTION
    This script installs latex-pdf-clean.ps1 to a location in your PATH so you can
    use it from anywhere on your system.

.PARAMETER InstallPath
    The directory where to install the script. Default is $HOME\bin
    The installer will add this directory to your PATH if it's not already there.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Installation directory")]
    [string]$InstallPath = "$HOME\bin"
)

$ErrorActionPreference = "Stop"

Write-Host "=== latex-pdf-clean Windows Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found!" -ForegroundColor Red
    Write-Host "  Please install Docker Desktop for Windows first:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Create installation directory if it doesn't exist
if (-not (Test-Path $InstallPath)) {
    Write-Host "Creating installation directory: $InstallPath" -ForegroundColor Yellow
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
}

# Copy the script
$scriptPath = Join-Path $PSScriptRoot "latex-pdf-clean.ps1"
$destPath = Join-Path $InstallPath "latex-pdf-clean.ps1"

Write-Host "Installing script to: $destPath" -ForegroundColor Yellow
Copy-Item -Path $scriptPath -Destination $destPath -Force

Write-Host "✓ Script installed successfully" -ForegroundColor Green
Write-Host ""

# Check if the installation path is in the user's PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$pathDirs = $userPath -split ';' | ForEach-Object { $_.Trim() }

if ($pathDirs -notcontains $InstallPath) {
    Write-Host "Adding $InstallPath to your PATH..." -ForegroundColor Yellow
    
    # Add to PATH
    $newPath = "$userPath;$InstallPath"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    
    # Update current session
    $env:PATH = "$env:PATH;$InstallPath"
    
    Write-Host "✓ Added to PATH (restart your terminal for system-wide effect)" -ForegroundColor Green
} else {
    Write-Host "✓ Installation directory is already in your PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Installation Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  latex-pdf-clean.ps1 yourfile.tex" -ForegroundColor Yellow
Write-Host "  latex-pdf-clean.ps1 -KeepLog yourfile.tex" -ForegroundColor Yellow
Write-Host "  latex-pdf-clean.ps1 -KeepAll yourfile.tex" -ForegroundColor Yellow
Write-Host ""
Write-Host "You may need to restart your terminal for the PATH change to take effect." -ForegroundColor Cyan
Write-Host ""

# Test the installation
Write-Host "Testing installation..." -ForegroundColor Yellow
try {
    # Refresh PATH in current session
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")
    
    $testCmd = Get-Command latex-pdf-clean.ps1 -ErrorAction SilentlyContinue
    if ($testCmd) {
        Write-Host "✓ latex-pdf-clean.ps1 is now available in your PATH" -ForegroundColor Green
    } else {
        Write-Host "⚠ Please restart your terminal to use latex-pdf-clean.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Please restart your terminal to use latex-pdf-clean.ps1" -ForegroundColor Yellow
}
