function Invoke-WinSetup {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [string[]]$Profiles = @('dev'),

    [ValidateSet('Auto', 'Winget', 'Choco')]
    [string]$PackageManager = 'Auto',

    [ValidateSet('Pinned', 'Latest')]
    [string]$InstallMode = 'Pinned',

    [switch]$NonInteractive,

    [string]$LogPath,

    [string]$JsonLogPath,

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

    [switch]$AutoReboot,

    [string]$RepoRoot
  )

  Assert-WinSetupIsWindows

  $root = Get-WinSetupRepoRoot -RepoRoot $RepoRoot

  if (-not $LogPath) {
    $logDir = Join-Path $env:LOCALAPPDATA 'WinSetup-Pro\logs'
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $LogPath = Join-Path $logDir ("winsetup-{0}.log" -f $stamp)
  }

  if (-not $JsonLogPath) {
    $JsonLogPath = [System.IO.Path]::ChangeExtension($LogPath, '.jsonl')
  }

  Write-WinSetupLog -Message ("RepoRoot: {0}" -f $root) -Level DEBUG -LogPath $LogPath -JsonLogPath $JsonLogPath
  Write-WinSetupLog -Message ("Profile: {0}" -f ($Profiles -join ', ')) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath

  # Wenn Chocolatey explizit gewuenscht ist, aber fehlt: Bootstrap ueber winget (kein remote iex).
  if ($PackageManager -eq 'Choco' -and -not (Get-Command choco -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
      Write-WinSetupLog -Message 'Chocolatey wurde angefordert, ist aber nicht installiert. Bootstrap ueber winget...' -Level WARN -LogPath $LogPath -JsonLogPath $JsonLogPath
      Install-WinSetupPackages `
        -PackageKeys @('chocolatey') `
        -PackageManager Winget `
        -InstallMode $InstallMode `
        -NonInteractive:$NonInteractive `
        -AllowPartial:$AllowPartial `
        -LogPath $LogPath `
        -RepoRoot $root `
        -WhatIf:$WhatIfPreference `
        -Confirm:$ConfirmPreference
    } else {
      throw 'Chocolatey wurde angefordert, aber weder choco noch winget ist verfuegbar. Installiere mindestens eines davon.'
    }
  }

  $plan = Get-WinSetupPlan `
    -Profiles $Profiles `
    -PackageManager $PackageManager `
    -InstallMode $InstallMode `
    -NonInteractive:$NonInteractive `
    -HomeAssistantMode $HomeAssistantMode `
    -DatabaseMode $DatabaseMode `
    -WebMode $WebMode `
    -RepoRoot $root

  Write-WinSetupLog -Message ("Plan Pakete: {0}" -f ($plan.packages -join ', ')) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath
  Write-WinSetupLog -Message ("Plan Dienste: db={0}, web={1}, ha={2}" -f $plan.services.database.mode, $plan.services.web.mode, $plan.services.homeAssistant.mode) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath

  $packagesToInstall = @($plan.packages)

  # Optional: Release-pinned Manifeste fuer Batch-Install nutzen und danach Einzelschritte fuer abgedeckte Pakete skippen.
  try {
    $resolvedPm = Resolve-WinSetupPackageManager -PackageManager $PackageManager
  } catch {
    $resolvedPm = $null
  }

  if ($resolvedPm -and ($InstallMode -in @('Pinned', 'Latest'))) {
    if ($resolvedPm -eq 'Winget') {
      $coveredIds = @{}
      foreach ($profileName in $Profiles) {
        $manifestPath = Join-Path $root ("manifests\\winget\\{0}.json" -f $profileName)
        if (-not (Test-Path $manifestPath)) { continue }

        Write-WinSetupLog -Message ("Nutze winget Manifest: {0}" -f $manifestPath) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath

        try {
          $m = Read-WinSetupJson -Path $manifestPath
          foreach ($p in @($m.Packages)) {
            if ($p.PackageIdentifier) { $coveredIds[[string]$p.PackageIdentifier] = $true }
          }
        } catch {
          Write-WinSetupLog -Message ("winget Manifest konnte nicht fuer Coverage geparst werden: {0}" -f $_.Exception.Message) -Level WARN -LogPath $LogPath -JsonLogPath $JsonLogPath
        }

        $importArgs = @(
          'import',
          '-i', $manifestPath,
          '--accept-source-agreements',
          '--accept-package-agreements',
          '--ignore-unavailable',
          '--no-upgrade'
        )

        if ($InstallMode -eq 'Latest') { $importArgs += '--ignore-versions' }
        if ($NonInteractive) { $importArgs += '--disable-interactivity' }

        if ($PSCmdlet.ShouldProcess($manifestPath, 'winget import')) {
          Invoke-WinSetupExternalCommand -FilePath 'winget' -ArgumentList $importArgs -LogPath $LogPath
        }
      }

      if ($coveredIds.Count -gt 0) {
        $packagesToInstall = @()
        foreach ($rp in @($plan.resolvedPackages)) {
          if ($rp.wingetId -and $coveredIds.ContainsKey([string]$rp.wingetId)) { continue }
          $packagesToInstall += [string]$rp.key
        }
      }
    }

    if ($resolvedPm -eq 'Choco') {
      $coveredIds = @{}
      foreach ($profileName in $Profiles) {
        $manifestPath = Join-Path $root ("manifests\\choco\\{0}\\packages.config" -f $profileName)
        if (-not (Test-Path $manifestPath)) { continue }

        Write-WinSetupLog -Message ("Nutze choco Manifest: {0}" -f $manifestPath) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath

        try {
          [xml]$xml = Get-Content -Path $manifestPath -Raw -Encoding utf8
          foreach ($node in @($xml.packages.package)) {
            if ($node.id) { $coveredIds[[string]$node.id] = $true }
          }
        } catch {
          Write-WinSetupLog -Message ("choco Manifest konnte nicht fuer Coverage geparst werden: {0}" -f $_.Exception.Message) -Level WARN -LogPath $LogPath -JsonLogPath $JsonLogPath
        }

        $chocoArgs = @('install', $manifestPath, '-y', '--no-progress')
        if ($NonInteractive) { $chocoArgs += '--limit-output' }

        if ($PSCmdlet.ShouldProcess($manifestPath, 'choco install packages.config')) {
          Invoke-WinSetupExternalCommand -FilePath 'choco' -ArgumentList $chocoArgs -LogPath $LogPath
        }
      }

      if ($coveredIds.Count -gt 0) {
        $packagesToInstall = @()
        foreach ($rp in @($plan.resolvedPackages)) {
          if ($rp.chocoId -and $coveredIds.ContainsKey([string]$rp.chocoId)) { continue }
          $packagesToInstall += [string]$rp.key
        }
      }
    }
  }

  if ($packagesToInstall.Count -ne $plan.packages.Count) {
    Write-WinSetupLog -Message ("Verbleibende Pakete nach Manifest-Import: {0}" -f ($packagesToInstall -join ', ')) -Level INFO -LogPath $LogPath -JsonLogPath $JsonLogPath
  }

  Install-WinSetupPackages `
    -PackageKeys $packagesToInstall `
    -PackageManager $PackageManager `
    -InstallMode $InstallMode `
    -NonInteractive:$NonInteractive `
    -AllowPartial:$AllowPartial `
    -LogPath $LogPath `
    -RepoRoot $root `
    -WhatIf:$WhatIfPreference `
    -Confirm:$ConfirmPreference

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

  Start-WinSetupServices `
    -Services $plan.services `
    -Operation Up `
    -RepoRoot $root `
    -AllowPartial:$AllowPartial `
    -LogPath $LogPath `
    -WhatIf:$WhatIfPreference `
    -Confirm:$ConfirmPreference

  if ($AutoReboot) {
    Write-WinSetupLog -Message 'AutoReboot ist gesetzt, aber ein automatischer Reboot ist noch nicht implementiert. Falls noetig: bitte manuell neu starten.' -Level WARN -LogPath $LogPath -JsonLogPath $JsonLogPath
  }

  Write-WinSetupLog -Message 'WinSetup abgeschlossen.' -Level SUCCESS -LogPath $LogPath -JsonLogPath $JsonLogPath
}
