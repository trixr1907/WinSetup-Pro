function Start-WinSetupServices {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [object]$Services,

    [ValidateSet('Up', 'Down', 'Status')]
    [string]$Operation = 'Up',

    [string]$RepoRoot,

    [switch]$AllowPartial,

    [string]$LogPath
  )

  Assert-WinSetupIsWindows

  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    $msg = 'docker ist nicht verfuegbar. Installiere zuerst Docker Desktop (Profil: dev).'
    if ($AllowPartial) {
      Write-WinSetupLog -Message $msg -Level WARN -LogPath $LogPath
      return
    }
    throw $msg
  }

  $root = Get-WinSetupRepoRoot -RepoRoot $RepoRoot

  $dataDir = Join-Path $env:LOCALAPPDATA 'WinSetup-Pro\data'
  if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
  }

  # docker compose ist bei Bind-Mounts auf Windows meist gluecklicher mit Forward-Slashes.
  $env:WINSETUP_DATA = $dataDir.Replace('\', '/')

  foreach ($svcName in @('database', 'web', 'homeAssistant')) {
    $svc = $Services.$svcName
    if (-not $svc) { continue }

    $mode = [string]$svc.mode
    $composeRel = [string]$svc.composeFile
    if (-not $mode) { $mode = 'Skip' }

    if ($mode -eq 'Skip') { continue }
    if ($mode -ne 'Container') {
      Write-WinSetupLog -Message ("Service '{0}' Mode '{1}' ist noch nicht implementiert (nutze Container oder Skip)." -f $svcName, $mode) -Level WARN -LogPath $LogPath
      continue
    }

    $composeFile = Join-Path $root $composeRel
    if (-not (Test-Path $composeFile)) {
      $msg = ("Compose-Datei nicht gefunden: {0}" -f $composeFile)
      if ($AllowPartial) {
        Write-WinSetupLog -Message $msg -Level WARN -LogPath $LogPath
        continue
      }
      throw $msg
    }

    $args = @('compose', '-f', $composeFile)
    switch ($Operation) {
      'Up' { $args += @('up', '-d') }
      'Down' { $args += @('down') }
      'Status' { $args += @('ps') }
    }

    if ($PSCmdlet.ShouldProcess($svcName, ("docker compose {0}" -f $Operation))) {
      try {
        Invoke-WinSetupExternalCommand -FilePath 'docker' -ArgumentList $args -LogPath $LogPath
        Write-WinSetupLog -Message ("Service '{0}': {1}" -f $svcName, $Operation) -Level SUCCESS -LogPath $LogPath
      } catch {
        if ($AllowPartial) {
          Write-WinSetupLog -Message $_.Exception.Message -Level ERROR -LogPath $LogPath
          continue
        }
        throw
      }
    }
  }
}
