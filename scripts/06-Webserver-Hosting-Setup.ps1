#requires -Version 7.0

# Rueckwaertskompatibler Einstiegspunkt. Empfehlung: scripts/Invoke-WinSetup.ps1
$compat = Join-Path $PSScriptRoot 'compat\06-Webserver-Hosting-Setup.ps1'
& $compat @args
