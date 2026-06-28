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
  [string]$WebMode = 'Container',

  [switch]$AllowPartial
)

$NonInteractive = $NonInteractive -or $SkipPrompts

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'src\WinSetup.Pro\WinSetup.Pro.psd1'
Import-Module $modulePath -Force

# Container-first. We only ensure Docker Desktop and then start the web compose stack.
Install-WinSetupPackages `
  -PackageKeys @('docker-desktop') `
  -PackageManager $PackageManager `
  -InstallMode $InstallMode `
  -NonInteractive:$NonInteractive `
  -AllowPartial:$AllowPartial `
  -LogPath $LogPath `
  -RepoRoot $repoRoot `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

$services = [pscustomobject]@{
  database = [pscustomobject]@{ mode = 'Skip'; composeFile = 'compose/db.compose.yaml' }
  web = [pscustomobject]@{ mode = $WebMode; composeFile = 'compose/web.compose.yaml' }
  homeAssistant = [pscustomobject]@{ mode = 'Skip'; composeFile = 'compose/ha.compose.yaml' }
}

Start-WinSetupServices `
  -Services $services `
  -Operation Up `
  -RepoRoot $repoRoot `
  -AllowPartial:$AllowPartial `
  -LogPath $LogPath `
  -WhatIf:$WhatIfPreference `
  -Confirm:$ConfirmPreference

