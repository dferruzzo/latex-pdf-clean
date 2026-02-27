#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup PowerShell alias for latex-pdf-clean

.DESCRIPTION
    This script adds a convenient alias to your PowerShell profile so you can use:
    - latex (instead of latex-pdf-clean.ps1)
    - lpc (short form)
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Setting up PowerShell aliases ===" -ForegroundColor Cyan
Write-Host ""

# Get the PowerShell profile path
$profilePath = $PROFILE.CurrentUserAllHosts

# Create profile directory if it doesn't exist
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) {
    Write-Host "Creating profile directory: $profileDir" -ForegroundColor Yellow
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}

# Get the script location
$scriptPath = Join-Path $PSScriptRoot "latex-pdf-clean.ps1"

# Alias configuration
$aliasConfig = @"

# LaTeX PDF Clean aliases
function Invoke-LatexPdfClean {
    param(
        [Parameter(Position=0, Mandatory=`$true)]
        [string]`$TexFile,
        [switch]`$KeepLog,
        [switch]`$KeepAll
    )
    & "$scriptPath" @PSBoundParameters
}

Set-Alias -Name latex -Value Invoke-LatexPdfClean -Force
Set-Alias -Name lpc -Value Invoke-LatexPdfClean -Force

Write-Host "LaTeX PDF Clean aliases loaded: latex, lpc" -ForegroundColor Green
"@

# Check if aliases already exist in profile
$profileExists = Test-Path $profilePath
$aliasesExist = $false

if ($profileExists) {
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -match "LaTeX PDF Clean aliases") {
        $aliasesExist = $true
        Write-Host "⚠ Aliases already exist in your PowerShell profile" -ForegroundColor Yellow
        $response = Read-Host "Update them? (Y/N)"
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
        
        # Remove old aliases
        $profileContent = $profileContent -replace '(?s)# LaTeX PDF Clean aliases.*?Write-Host.*?Green\s*', ''
        Set-Content -Path $profilePath -Value $profileContent.Trim()
    }
}

# Add aliases to profile
Write-Host "Adding aliases to PowerShell profile..." -ForegroundColor Yellow
Add-Content -Path $profilePath -Value $aliasConfig

Write-Host "✓ Aliases added successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Available aliases:" -ForegroundColor Cyan
Write-Host "  latex your-file.tex       (full alias)" -ForegroundColor Yellow
Write-Host "  lpc your-file.tex          (short form)" -ForegroundColor Yellow
Write-Host "  latex -KeepLog file.tex   (with options)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Restart your PowerShell terminal or run:" -ForegroundColor White
Write-Host "  . `$PROFILE" -ForegroundColor Yellow
Write-Host ""
