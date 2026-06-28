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

# Curated replacement for legacy "automation" step:
# - Use server profile (Azure CLI, Terraform, kubectl, etc.)
# - Add dev profile if you also want GitHub CLI and IDE tooling.
Invoke-WinSetup `
  -Profiles @('server') `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -LogPath $LogPath `
  -AllowPartial:$AllowPartial `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

