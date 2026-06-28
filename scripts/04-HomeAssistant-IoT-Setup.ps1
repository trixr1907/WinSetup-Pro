#requires -Version 7.0

# Rueckwaertskompatibler Einstiegspunkt. Empfehlung: scripts/Invoke-WinSetup.ps1
$compat = Join-Path $PSScriptRoot 'compat\04-HomeAssistant-IoT-Setup.ps1'
& $compat @args
