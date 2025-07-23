# ===================================================================
# Server und Virtualisierung-Tools Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Automatisierte Installation der Server und Virtualisierung-Tools
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Server-Virtualization-Setup.log"
)

# Logging-Funktion
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

# Prüfe Administrator-Rechte
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Log "=== Server und Virtualisierung-Tools Setup gestartet ==="

if (-not (Test-Administrator)) {
    Write-Log "WARNUNG: Skript läuft nicht als Administrator. Einige Funktionen könnten fehlschlagen." "WARNING"
    if (-not $SkipPrompts) {
        $continue = Read-Host "Trotzdem fortfahren? (y/N)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            Write-Log "Setup abgebrochen durch Benutzer." "INFO"
            exit 1
        }
    }
}

try {
    # Hyper-V Features aktivieren (falls verfügbar)
    Write-Log "Prüfe Hyper-V Verfügbarkeit..."
    $hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    if ($hypervFeature -and $hypervFeature.State -eq "Disabled") {
        Write-Log "Aktiviere Hyper-V..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
        Write-Log "Hyper-V aktiviert (Neustart erforderlich)"
    } else {
        Write-Log "Hyper-V bereits aktiviert oder nicht verfügbar"
    }

    # Docker Desktop installieren
    Write-Log "Installiere Docker Desktop..."
    winget install Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
    Write-Log "Docker Desktop installiert"

    # VirtualBox installieren
    Write-Log "Installiere VirtualBox..."
    winget install Oracle.VirtualBox --accept-source-agreements --accept-package-agreements
    Write-Log "VirtualBox installiert"

    # VMware Workstation Player (kostenlos)
    Write-Log "Installiere VMware Workstation Player..."
    winget install VMware.WorkstationPlayer --accept-source-agreements --accept-package-agreements
    Write-Log "VMware Workstation Player installiert"

    # Remote Desktop Tools
    Write-Log "Installiere Remote Desktop Tools..."
    winget install Microsoft.RemoteDesktopConnection --accept-source-agreements --accept-package-agreements
    Write-Log "Remote Desktop Connection installiert"

    # PuTTY für SSH
    Write-Log "Installiere PuTTY..."
    winget install PuTTY.PuTTY --accept-source-agreements --accept-package-agreements
    Write-Log "PuTTY installiert"

    # WinSCP für SFTP
    Write-Log "Installiere WinSCP..."
    winget install WinSCP.WinSCP --accept-source-agreements --accept-package-agreements
    Write-Log "WinSCP installiert"

    # Kubernetes Tools
    Write-Log "Installiere kubectl..."
    winget install Kubernetes.kubectl --accept-source-agreements --accept-package-agreements
    Write-Log "kubectl installiert"

    # Terraform für Infrastructure as Code
    Write-Log "Installiere Terraform..."
    winget install HashiCorp.Terraform --accept-source-agreements --accept-package-agreements
    Write-Log "Terraform installiert"

    # Vagrant für VM Management
    Write-Log "Installiere Vagrant..."
    winget install HashiCorp.Vagrant --accept-source-agreements --accept-package-agreements
    Write-Log "Vagrant installiert"

    # Server-Monitoring Tools
    Write-Log "Installiere Wireshark..."
    winget install WiresharkFoundation.Wireshark --accept-source-agreements --accept-package-agreements
    Write-Log "Wireshark installiert"

    # Backup-Verzeichnisse für VMs erstellen
    $vmBackupDir = "$env:USERPROFILE\VM-Backups"
    if (-not (Test-Path $vmBackupDir)) {
        New-Item -ItemType Directory -Path $vmBackupDir
        Write-Log "VM-Backup-Verzeichnis erstellt: $vmBackupDir"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Server und Virtualisierung-Tools Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ Hyper-V (Windows Feature)
✓ Docker Desktop
✓ VirtualBox
✓ VMware Workstation Player
✓ Remote Desktop Connection
✓ PuTTY
✓ WinSCP
✓ kubectl
✓ Terraform
✓ Vagrant
✓ Wireshark

VM-Backup-Verzeichnis:
- $vmBackupDir

Nächste Schritte:
- Docker Desktop einrichten und testen
- VirtualBox VMs importieren/erstellen
- Kubernetes Cluster konfigurieren
- SSH-Keys für Remote-Zugriff einrichten

HINWEIS: Neustart erforderlich für Hyper-V-Aktivierung
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Server und Virtualisierung-Tools Setup abgeschlossen!"
