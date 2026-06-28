function Install-WinSetupPackages {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [string[]]$PackageKeys,

    [ValidateSet('Auto', 'Winget', 'Choco')]
    [string]$PackageManager = 'Auto',

    [ValidateSet('Pinned', 'Latest')]
    [string]$InstallMode = 'Pinned',

    [switch]$NonInteractive,

    [switch]$AllowPartial,

    [string]$LogPath,

    [string]$RepoRoot
  )

  Assert-WinSetupIsWindows

  $root = Get-WinSetupRepoRoot -RepoRoot $RepoRoot
  $catalog = Read-WinSetupJson -Path (Join-Path $root 'packages\catalog.json')
  $catalogIndex = Get-WinSetupCatalogIndex -Catalog $catalog

  $pm = Resolve-WinSetupPackageManager -PackageManager $PackageManager
  $isAdmin = Test-WinSetupIsAdministrator

  foreach ($originalKey in $PackageKeys) {
    $key = [string]$originalKey
    if ([string]::IsNullOrWhiteSpace($key)) { continue }

    $pkg = $catalogIndex[$key]
    if (-not $pkg) {
      throw ("Unbekannter Package-Key: {0}" -f $key)
    }

    if ($pkg.deprecated -and $pkg.replacementKey) {
      Write-WinSetupLog -Message ("Package '{0}' ist deprecated; nutze '{1}'." -f $key, $pkg.replacementKey) -Level WARN -LogPath $LogPath
      $key = [string]$pkg.replacementKey
      $pkg = $catalogIndex[$key]
      if (-not $pkg) { throw ("Replacement-Package nicht im Catalog gefunden: {0}" -f $key) }
    }

    if ($pkg.requiresAdmin -and -not $isAdmin) {
      $msg = ("Package '{0}' erfordert Administrator-Rechte." -f $key)
      if ($AllowPartial) {
        Write-WinSetupLog -Message $msg -Level WARN -LogPath $LogPath
        continue
      }
      throw $msg
    }

    try {
      if ($pm -eq 'Winget') {
        $id = [string]$pkg.winget.id
        if ([string]::IsNullOrWhiteSpace($id)) { throw ("Kein winget.id fuer Package '{0}' konfiguriert." -f $key) }

        $args = @(
          'install',
          '--id', $id,
          '-e',
          '--source', ([string]($pkg.winget.source ?? 'winget')),
          '--accept-source-agreements',
          '--accept-package-agreements'
        )

        if ($InstallMode -eq 'Pinned' -and $pkg.winget.versionPinned) {
          $args += @('--version', [string]$pkg.winget.versionPinned)
        }

        if ($NonInteractive) {
          $args += @('--silent', '--disable-interactivity')
        }

        if ($PSCmdlet.ShouldProcess($id, 'winget install')) {
          Invoke-WinSetupExternalCommand -FilePath 'winget' -ArgumentList $args -LogPath $LogPath
          Write-WinSetupLog -Message ("Installiert (winget): {0}" -f $id) -Level SUCCESS -LogPath $LogPath
        }
      } else {
        $id = [string]$pkg.choco.id
        if ([string]::IsNullOrWhiteSpace($id)) { throw ("Kein choco.id fuer Package '{0}' konfiguriert." -f $key) }

        $args = @('install', $id, '-y', '--no-progress')

        if ($InstallMode -eq 'Pinned' -and $pkg.choco.versionPinned) {
          $args += @('--version', [string]$pkg.choco.versionPinned)
        }

        if ($NonInteractive) {
          $args += @('--limit-output')
        }

        if ($PSCmdlet.ShouldProcess($id, 'choco install')) {
          Invoke-WinSetupExternalCommand -FilePath 'choco' -ArgumentList $args -LogPath $LogPath
          Write-WinSetupLog -Message ("Installiert (choco): {0}" -f $id) -Level SUCCESS -LogPath $LogPath
        }
      }
    } catch {
      if ($AllowPartial) {
        Write-WinSetupLog -Message $_.Exception.Message -Level ERROR -LogPath $LogPath
        continue
      }
      throw
    }
  }
}
