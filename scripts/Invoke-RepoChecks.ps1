#requires -Version 7.0

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host "RepoRoot: $repoRoot"

try {
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction Stop
} catch {
  # Ignore if PSGallery isn't available in the current environment.
}

try {
  if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
  }
} catch {
  # Ignore if package providers can't be installed in the current environment.
}

Write-Host "Installiere PowerShell-Module (Pester, PSScriptAnalyzer), falls nicht vorhanden..."
if (-not (Get-Module -ListAvailable -Name Pester)) {
  Install-Module Pester -Force -Scope CurrentUser
}
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
  Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
}

Import-Module PSScriptAnalyzer -Force

$settingsPath = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
if (-not (Test-Path $settingsPath)) {
  throw ("PSScriptAnalyzer Settings nicht gefunden: {0}" -f $settingsPath)
}

Write-Host "Starte PSScriptAnalyzer..."
$analysisPaths = @(
  (Join-Path $repoRoot 'src')
  (Join-Path $repoRoot 'scripts')
  (Join-Path $repoRoot 'tests')
)
$analysis = foreach ($analysisPath in $analysisPaths) {
  Invoke-ScriptAnalyzer -Path $analysisPath -Recurse -Settings $settingsPath
}
if ($analysis -and $analysis.Count -gt 0) {
  $analysis | Sort-Object Severity, RuleName, ScriptName | Format-Table -AutoSize | Out-String | Write-Host

  $errors = @($analysis | Where-Object { $_.Severity -eq 'Error' })
  if ($errors.Count -gt 0) {
    throw ("PSScriptAnalyzer hat {0} Error(s) gefunden." -f $errors.Count)
  }
}

Write-Host "Starte Pester..."
Import-Module Pester -Force
Invoke-Pester -Path (Join-Path $repoRoot 'tests') -CI -Output Detailed
