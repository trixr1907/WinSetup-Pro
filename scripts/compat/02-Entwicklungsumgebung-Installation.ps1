#requires -Version 7.0

[CmdletBinding(SupportsShouldProcess)]
param(
  [ValidateSet('Auto', 'Winget', 'Choco')]
  [string]$PackageManager = 'Auto',

  [ValidateSet('Pinned', 'Latest')]
  [string]$InstallMode = 'Pinned',

  [switch]$NonInteractive,

  [Alias('SkipPrompts')]
  [switch]$SkipPrompts,

  [string]$LogPath,

  [switch]$EnableFirewallDevPorts,
  [switch]$EnableDefenderExclusions,

  [string]$GitUserName,
  [string]$GitUserEmail,

  [switch]$AllowPartial,

  [switch]$AutoReboot
)

$NonInteractive = $NonInteractive -or $SkipPrompts

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'
Import-Module $modulePath -Force

Invoke-WinSetup `
  -Profiles @('dev') `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -LogPath $LogPath `
  -EnableFirewallDevPorts:$EnableFirewallDevPorts `
  -EnableDefenderExclusions:$EnableDefenderExclusions `
  -GitUserName $GitUserName `
  -GitUserEmail $GitUserEmail `
  -AllowPartial:$AllowPartial `
  -AutoReboot:$AutoReboot `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

