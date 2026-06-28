#requires -Version 7.0

Set-StrictMode -Version Latest

$publicDir = Join-Path $PSScriptRoot 'Public'
$privateDir = Join-Path $PSScriptRoot 'Private'

foreach ($dir in @($privateDir, $publicDir)) {
  if (-not (Test-Path $dir)) { continue }
  Get-ChildItem -Path $dir -Filter '*.ps1' -File | ForEach-Object {
    . $_.FullName
  }
}

Export-ModuleMember -Function @(
  'Invoke-WinSetup',
  'Get-WinSetupPlan',
  'Install-WinSetupPackages',
  'Invoke-WinSetupActions',
  'Start-WinSetupServices',
  'Write-WinSetupLog'
)

