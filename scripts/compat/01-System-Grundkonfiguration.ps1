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

  [switch]$AllowPartial
)

$NonInteractive = $NonInteractive -or $SkipPrompts

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'
Import-Module $modulePath -Force

# Baseline is safe by default: no system/policy changes without opt-in.
$plan = Get-WinSetupPlan -Profiles dev -PackageManager $PackageManager -InstallMode $InstallMode -NonInteractive:$NonInteractive -RepoRoot $repoRoot

Invoke-WinSetupActions `
  -Actions $plan.actions `
  -EnableFirewallDevPorts:$EnableFirewallDevPorts `
  -EnableDefenderExclusions:$EnableDefenderExclusions `
  -GitUserName $GitUserName `
  -GitUserEmail $GitUserEmail `
  -NonInteractive:$NonInteractive `
  -AllowPartial:$AllowPartial `
  -LogPath $LogPath `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference
