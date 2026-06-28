#requires -Version 7.0

# Rueckwaertskompatibler Einstiegspunkt. Empfehlung: scripts/Invoke-WinSetup.ps1
$compat = Join-Path $PSScriptRoot 'compat\07-Security-Monitoring-Setup.ps1'
& $compat @args
