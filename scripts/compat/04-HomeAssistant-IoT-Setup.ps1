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

  [ValidateSet('Container', 'Native', 'Skip')]
  [string]$HomeAssistantMode = 'Container',

  [switch]$AllowPartial
)

$NonInteractive = $NonInteractive -or $SkipPrompts

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'
Import-Module $modulePath -Force

Invoke-WinSetup `
  -Profiles @('iot') `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -LogPath $LogPath `
  -HomeAssistantMode $HomeAssistantMode `
  -AllowPartial:$AllowPartial `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

