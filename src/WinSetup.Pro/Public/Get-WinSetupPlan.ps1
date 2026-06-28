function Get-WinSetupPlan {
  [CmdletBinding()]
  param(
    [string[]]$Profiles = @('dev'),

    [ValidateSet('Auto', 'Winget', 'Choco')]
    [string]$PackageManager = 'Auto',

    [ValidateSet('Pinned', 'Latest')]
    [string]$InstallMode = 'Pinned',

    [switch]$NonInteractive,

    [ValidateSet('Container', 'Native', 'Skip')]
    [string]$HomeAssistantMode,

    [ValidateSet('Container', 'Native', 'Skip')]
    [string]$DatabaseMode,

    [ValidateSet('Container', 'Native', 'Skip')]
    [string]$WebMode,

    [string]$RepoRoot
  )

  Assert-WinSetupIsWindows

  $root = Get-WinSetupRepoRoot -RepoRoot $RepoRoot
  $catalog = Read-WinSetupJson -Path (Join-Path $root 'packages\catalog.json')
  $catalogIndex = Get-WinSetupCatalogIndex -Catalog $catalog

  $profilesDir = Join-Path $root 'profiles'

  $pkgSeen = @{}
  $packages = New-Object System.Collections.Generic.List[string]

  $actionOrder = New-Object System.Collections.Generic.List[string]
  $actionMap = @{}

  $services = @{
    database = @{ mode = 'Skip'; composeFile = 'compose/db.compose.yaml' }
    web = @{ mode = 'Skip'; composeFile = 'compose/web.compose.yaml' }
    homeAssistant = @{ mode = 'Skip'; composeFile = 'compose/ha.compose.yaml' }
  }

  foreach ($profileName in $Profiles) {
    $profilePath = Join-Path $profilesDir ($profileName + '.json')
    if (-not (Test-Path $profilePath)) {
      throw ("Unbekanntes Profil: {0} (erwartet: {1})" -f $profileName, $profilePath)
    }

    $p = Read-WinSetupJson -Path $profilePath

    foreach ($k in @($p.packages)) {
      if (-not $k) { continue }
      if (-not $pkgSeen.ContainsKey($k)) {
        $pkgSeen[$k] = $true
        [void]$packages.Add([string]$k)
      }
    }

    foreach ($a in @($p.actions)) {
      if (-not $a -or -not $a.id) { continue }
      $id = [string]$a.id

      if (-not $actionMap.ContainsKey($id)) {
        [void]$actionOrder.Add($id)
        $actionMap[$id] = [ordered]@{ id = $id; options = @{} }
      }

      if ($a.options) {
        foreach ($prop in $a.options.PSObject.Properties) {
          $actionMap[$id].options[$prop.Name] = $prop.Value
        }
      }
    }

    if ($p.services) {
      foreach ($svcName in @('database', 'web', 'homeAssistant')) {
        if ($p.services.$svcName) {
          $svc = $p.services.$svcName
          if ($svc.mode) { $services[$svcName].mode = [string]$svc.mode }
          if ($svc.composeFile) { $services[$svcName].composeFile = [string]$svc.composeFile }
        }
      }
    }
  }

  if ($DatabaseMode) { $services.database.mode = $DatabaseMode }
  if ($WebMode) { $services.web.mode = $WebMode }
  if ($HomeAssistantMode) { $services.homeAssistant.mode = $HomeAssistantMode }

  $actions = foreach ($id in $actionOrder) {
    [pscustomobject]$actionMap[$id]
  }

  $resolvedPackages = foreach ($key in $packages) {
    $pkg = $catalogIndex[$key]
    if (-not $pkg) { throw ("Unbekannter Package-Key (aus Profil referenziert): {0}" -f $key) }
    [pscustomobject]@{
      key = $key
      wingetId = $pkg.winget.id
      chocoId = $pkg.choco.id
      requiresAdmin = [bool]$pkg.requiresAdmin
      deprecated = [bool]$pkg.deprecated
      replacementKey = $pkg.replacementKey
    }
  }

  [pscustomobject]@{
    repoRoot = $root
    profiles = $Profiles
    packageManager = $PackageManager
    installMode = $InstallMode
    nonInteractive = [bool]$NonInteractive
    packages = @($packages)
    resolvedPackages = @($resolvedPackages)
    actions = @($actions)
    services = $services
  }
}
