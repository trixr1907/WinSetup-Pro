#requires -Version 7.0

[CmdletBinding(SupportsShouldProcess)]
param(
  [string[]]$Profiles = @('dev'),

  [ValidateSet('Auto', 'Winget', 'Choco')]
  [string]$PackageManager = 'Auto',

  [ValidateSet('Pinned', 'Latest')]
  [string]$InstallMode = 'Pinned',

  [switch]$NonInteractive,

  [string]$LogPath,

  [ValidateSet('Container', 'Native', 'Skip')]
  [string]$HomeAssistantMode,

  [ValidateSet('Container', 'Native', 'Skip')]
  [string]$DatabaseMode,

  [ValidateSet('Container', 'Native', 'Skip')]
  [string]$WebMode,

  [switch]$EnableFirewallDevPorts,
  [switch]$EnableDefenderExclusions,

  [string]$GitUserName,
  [string]$GitUserEmail,

  [switch]$AllowPartial,

  [switch]$AutoReboot
)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'

if (-not (Test-Path $modulePath)) {
  throw ("Modul nicht gefunden: {0}" -f $modulePath)
}

Import-Module $modulePath -Force

Invoke-WinSetup `
  -Profiles $Profiles `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -LogPath $LogPath `
  -HomeAssistantMode $HomeAssistantMode `
  -DatabaseMode $DatabaseMode `
  -WebMode $WebMode `
  -EnableFirewallDevPorts:$EnableFirewallDevPorts `
  -EnableDefenderExclusions:$EnableDefenderExclusions `
  -GitUserName $GitUserName `
  -GitUserEmail $GitUserEmail `
  -AllowPartial:$AllowPartial `
  -AutoReboot:$AutoReboot `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference
