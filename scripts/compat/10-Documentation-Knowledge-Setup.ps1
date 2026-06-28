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

  [switch]$AllowPartial
)

$NonInteractive = $NonInteractive -or $SkipPrompts

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'
Import-Module $modulePath -Force

Invoke-WinSetup `
  -Profiles @('docs') `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -LogPath $LogPath `
  -AllowPartial:$AllowPartial `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

