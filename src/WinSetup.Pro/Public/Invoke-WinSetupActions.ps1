function Invoke-WinSetupActions {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [object[]]$Actions,

    [switch]$EnableFirewallDevPorts,
    [switch]$EnableDefenderExclusions,

    [string]$GitUserName,
    [string]$GitUserEmail,

    [switch]$NonInteractive,
    [switch]$AllowPartial,

    [string]$LogPath
  )

  Assert-WinSetupIsWindows

  foreach ($action in $Actions) {
    if (-not $action -or -not $action.id) { continue }
    $id = [string]$action.id
    $options = $action.options

    try {
      switch ($id) {
        'folders.dev' {
          $folders = @(
            (Join-Path $env:USERPROFILE 'Documents\GitHub'),
            (Join-Path $env:USERPROFILE 'Documents\Projects'),
            (Join-Path $env:USERPROFILE 'Documents\Projects\Web')
          )

          foreach ($folder in $folders) {
            if ($PSCmdlet.ShouldProcess($folder, 'Verzeichnis sicherstellen')) {
              if (-not (Test-Path $folder)) {
                New-Item -ItemType Directory -Path $folder -Force | Out-Null
              }
            }
          }

          Write-WinSetupLog -Message 'Entwicklungsordner sichergestellt.' -Level SUCCESS -LogPath $LogPath
        }

        'git.configure' {
          if ([string]::IsNullOrWhiteSpace($GitUserName) -or [string]::IsNullOrWhiteSpace($GitUserEmail)) {
            Write-WinSetupLog -Message 'Git-Identity wird uebersprungen (zum Aktivieren: -GitUserName und -GitUserEmail setzen).' -Level INFO -LogPath $LogPath
            break
          }

          if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-WinSetupLog -Message 'Git-Konfiguration wird uebersprungen (git nicht im PATH gefunden).' -Level WARN -LogPath $LogPath
            break
          }

          if ($PSCmdlet.ShouldProcess('git config --global', 'Git-Identity konfigurieren')) {
            Invoke-WinSetupExternalCommand -FilePath 'git' -ArgumentList @('config', '--global', 'user.name', $GitUserName) -LogPath $LogPath
            Invoke-WinSetupExternalCommand -FilePath 'git' -ArgumentList @('config', '--global', 'user.email', $GitUserEmail) -LogPath $LogPath
            Invoke-WinSetupExternalCommand -FilePath 'git' -ArgumentList @('config', '--global', 'init.defaultBranch', 'main') -LogPath $LogPath
          }

          Write-WinSetupLog -Message 'Git globale Identity konfiguriert.' -Level SUCCESS -LogPath $LogPath
        }

        'firewall.devPorts' {
          if (-not $EnableFirewallDevPorts) {
            Write-WinSetupLog -Message 'Firewall Dev-Ports uebersprungen (Opt-in via -EnableFirewallDevPorts).' -Level DEBUG -LogPath $LogPath
            break
          }

          if (-not (Test-WinSetupIsAdministrator)) {
            $msg = 'Firewall-Regel-Aenderungen erfordern Administrator-Rechte.'
            if ($AllowPartial) {
              Write-WinSetupLog -Message $msg -Level WARN -LogPath $LogPath
              break
            }
            throw $msg
          }

          $ports = @()
          if ($options -and $options.ports) { $ports = @($options.ports) }
          if (-not $ports -or $ports.Count -eq 0) { $ports = @(3000, 8000, 8080) }

          foreach ($port in $ports) {
            $ruleName = "WinSetup-Pro Dev TCP $port In"

            if ($PSCmdlet.ShouldProcess($ruleName, 'Firewall-Regel sicherstellen')) {
              $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
              if (-not $existing) {
                New-NetFirewallRule `
                  -DisplayName $ruleName `
                  -Direction Inbound `
                  -Action Allow `
                  -Protocol TCP `
                  -LocalPort $port `
                  -Profile Private `
                  -RemoteAddress LocalSubnet | Out-Null
              }
            }
          }

          Write-WinSetupLog -Message 'Inbound Dev-Firewall-Regeln sichergestellt (Private + LocalSubnet).' -Level SUCCESS -LogPath $LogPath
        }

        'defender.exclusions' {
          if (-not $EnableDefenderExclusions) {
            Write-WinSetupLog -Message 'Defender Exclusions uebersprungen (Opt-in via -EnableDefenderExclusions).' -Level DEBUG -LogPath $LogPath
            break
          }

          if (-not (Test-WinSetupIsAdministrator)) {
            $msg = 'Windows Defender Exclusions erfordern Administrator-Rechte.'
            if ($AllowPartial) {
              Write-WinSetupLog -Message $msg -Level WARN -LogPath $LogPath
              break
            }
            throw $msg
          }

          $paths = @()
          if ($options -and $options.paths) { $paths = @($options.paths) }
          foreach ($p in $paths) {
            $expanded = Expand-WinSetupString -Value ([string]$p)
            if (-not (Test-Path $expanded)) { continue }
            if ($PSCmdlet.ShouldProcess($expanded, 'Defender Exclusion hinzufuegen (Add-MpPreference -ExclusionPath)')) {
              Add-MpPreference -ExclusionPath $expanded -ErrorAction Stop
            }
          }

          Write-WinSetupLog -Message 'Defender Exclusions angewendet (Opt-in).' -Level SUCCESS -LogPath $LogPath
        }

        default {
          Write-WinSetupLog -Message ("Unbekannte Action-ID: {0}" -f $id) -Level WARN -LogPath $LogPath
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
