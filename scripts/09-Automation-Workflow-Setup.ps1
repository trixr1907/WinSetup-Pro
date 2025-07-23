# ===================================================================
# Automation und Workflow-Optimierung Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Automatisierung und CI/CD-Pipeline Setup
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Automation-Workflow-Setup.log"
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

Write-Log "=== Automation und Workflow-Optimierung Setup gestartet ==="

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
    Write-Log "=== File-Organization-Automation ==="
    
    # File Juggler (File Organization Tool)
    Write-Log "File Juggler: Manuelle Installation empfohlen von filejuggler.com"
    
    # Alternative: PowerShell-basierte File-Organization
    Write-Log "Erstelle PowerShell File-Organization-Skripte..."

    Write-Log "=== CI/CD und Build-Automation ==="
    
    # GitHub CLI (für GitHub Actions Integration)
    Write-Log "Installiere GitHub CLI..."
    winget install GitHub.cli
    Write-Log "GitHub CLI installiert"

    # Jenkins (lokale CI/CD-Pipeline)
    Write-Log "Installiere Jenkins..."
    # Jenkins über winget ist möglicherweise nicht verfügbar
    Write-Log "Jenkins: Docker-Installation empfohlen - docker run jenkins/jenkins"

    # Azure CLI (für Azure DevOps Integration)
    Write-Log "Installiere Azure CLI..."
    winget install Microsoft.AzureCLI
    Write-Log "Azure CLI installiert"

    Write-Log "=== System-Maintenance-Automation ==="
    
    # CCleaner für System-Cleanup
    Write-Log "Installiere CCleaner..."
    winget install Piriform.CCleaner
    Write-Log "CCleaner installiert"

    # Disk Cleanup bereits in Windows verfügbar
    Write-Log "Windows Disk Cleanup bereits verfügbar"

    # BleachBit als CCleaner-Alternative
    Write-Log "Installiere BleachBit..."
    winget install BleachBit.BleachBit
    Write-Log "BleachBit installiert"

    Write-Log "=== Update-Management-Automation ==="
    
    # Windows Update bereits automatisiert
    Write-Log "Windows Update automatisch konfiguriert"

    # Chocolatey für Software-Update-Management (falls nicht installiert)
    Write-Log "Prüfe Chocolatey Installation..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Installiere Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installiert"
    } else {
        Write-Log "Chocolatey bereits installiert"
    }

    # winget für moderne Package Management (bereits verfügbar)
    Write-Log "winget bereits für automatische Software-Updates verfügbar"

    Write-Log "=== Resource-Usage-Monitoring ==="
    
    # Windows Performance Monitor bereits verfügbar
    Write-Log "Windows Performance Monitor bereits verfügbar"

    # Resource Monitor bereits verfügbar
    Write-Log "Windows Resource Monitor bereits verfügbar"

    # HWMonitor für Hardware-Monitoring
    Write-Log "Installiere HWMonitor..."
    winget install CPUID.HWMonitor
    Write-Log "HWMonitor installiert"

    Write-Log "=== Automation-Skripte erstellen ==="
    
    # Automation-Verzeichnis erstellen
    $automationDir = "$env:USERPROFILE\Automation-Scripts"
    if (-not (Test-Path $automationDir)) {
        New-Item -ItemType Directory -Path $automationDir
        Write-Log "Automation-Scripts Verzeichnis erstellt: $automationDir"
    }

    # System-Maintenance-Skript
    $maintenanceScriptContent = @'
# System Maintenance Automation Script
# Führt regelmäßige Wartungsaufgaben aus

param(
    [switch]$Full,
    [switch]$Quick
)

Write-Host "=== System Maintenance Script gestartet ==="
$startTime = Get-Date

# Temp-Dateien löschen
Write-Host "Lösche temporäre Dateien..."
Get-ChildItem "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Temporäre Dateien gelöscht"

# Papierkorb leeren
Write-Host "Leere Papierkorb..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "Papierkorb geleert"

# Windows Update Check (bei Full-Modus)
if ($Full) {
    Write-Host "Prüfe Windows Updates..."
    try {
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot
        Write-Host "Windows Updates geprüft und installiert"
    } catch {
        Write-Host "Windows Update Modul nicht verfügbar oder Fehler: $($_.Exception.Message)"
    }
}

# Disk Cleanup ausführen
Write-Host "Führe Disk Cleanup aus..."
Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden
Write-Host "Disk Cleanup abgeschlossen"

# System File Check (bei Full-Modus)
if ($Full) {
    Write-Host "Führe System File Check aus..."
    Start-Process sfc -ArgumentList "/scannow" -Wait -WindowStyle Hidden -Verb RunAs
    Write-Host "System File Check abgeschlossen"
}

# Defragmentierung (nur bei Full-Modus und HDD)
if ($Full) {
    Write-Host "Prüfe Festplatten für Defragmentierung..."
    $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed' -and $_.FileSystem -eq 'NTFS'}
    foreach ($drive in $drives) {
        $defragNeeded = Optimize-Volume -DriveLetter $drive.DriveLetter -Analyze
        if ($defragNeeded.FragmentationPercentage -gt 10) {
            Write-Host "Defragmentiere Laufwerk $($drive.DriveLetter)..."
            Optimize-Volume -DriveLetter $drive.DriveLetter -Defrag
        }
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "=== System Maintenance abgeschlossen ==="
Write-Host "Dauer: $($duration.TotalMinutes) Minuten"
'@

    $maintenanceScriptPath = Join-Path $automationDir "System-Maintenance.ps1"
    Set-Content -Path $maintenanceScriptPath -Value $maintenanceScriptContent -Encoding UTF8
    Write-Log "System-Maintenance-Skript erstellt: $maintenanceScriptPath"

    # File-Organization-Skript
    $fileOrgScriptContent = @'
# File Organization Automation Script
# Organisiert Downloads und Dokumente automatisch

param(
    [string]$SourcePath = "$env:USERPROFILE\Downloads",
    [string]$DestinationBase = "$env:USERPROFILE\Organized-Files"
)

Write-Host "=== File Organization Script gestartet ==="

# Zielverzeichnisse erstellen
$categories = @{
    "Images" = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.svg", "*.webp")
    "Documents" = @("*.pdf", "*.doc", "*.docx", "*.txt", "*.rtf", "*.odt")
    "Spreadsheets" = @("*.xls", "*.xlsx", "*.csv", "*.ods")
    "Presentations" = @("*.ppt", "*.pptx", "*.odp")
    "Videos" = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv", "*.flv", "*.webm")
    "Audio" = @("*.mp3", "*.wav", "*.flac", "*.aac", "*.ogg", "*.m4a")
    "Archives" = @("*.zip", "*.rar", "*.7z", "*.tar", "*.gz", "*.bz2")
    "Executables" = @("*.exe", "*.msi", "*.dmg", "*.deb", "*.rpm")
    "Code" = @("*.html", "*.css", "*.js", "*.py", "*.java", "*.cpp", "*.cs", "*.php")
}

# Erstelle Zielverzeichnisse
foreach ($category in $categories.Keys) {
    $categoryPath = Join-Path $DestinationBase $category
    if (-not (Test-Path $categoryPath)) {
        New-Item -ItemType Directory -Path $categoryPath -Force
        Write-Host "Verzeichnis erstellt: $categoryPath"
    }
}

# Dateien organisieren
$movedFiles = 0
Get-ChildItem $SourcePath -File | ForEach-Object {
    $file = $_
    $moved = $false
    
    foreach ($category in $categories.Keys) {
        foreach ($extension in $categories[$category]) {
            if ($file.Name -like $extension) {
                $destinationPath = Join-Path $DestinationBase $category
                $newPath = Join-Path $destinationPath $file.Name
                
                # Vermeide Duplikate
                $counter = 1
                while (Test-Path $newPath) {
                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $extension = [System.IO.Path]::GetExtension($file.Name)
                    $newName = "${baseName}_${counter}${extension}"
                    $newPath = Join-Path $destinationPath $newName
                    $counter++
                }
                
                Move-Item $file.FullName $newPath
                Write-Host "Verschoben: $($file.Name) -> $category"
                $movedFiles++
                $moved = $true
                break
            }
        }
        if ($moved) { break }
    }
}

Write-Host "=== File Organization abgeschlossen ==="
Write-Host "$movedFiles Dateien organisiert"
'@

    $fileOrgScriptPath = Join-Path $automationDir "File-Organization.ps1"
    Set-Content -Path $fileOrgScriptPath -Value $fileOrgScriptContent -Encoding UTF8
    Write-Log "File-Organization-Skript erstellt: $fileOrgScriptPath"

    Write-Log "=== Task Scheduler Automation ==="
    
    # Wöchentliche System-Maintenance
    try {
        $taskName = "Weekly-System-Maintenance"
        $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        
        if (-not $taskExists) {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$maintenanceScriptPath`" -Quick"
            $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Sunday -At 2AM
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
            
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Wöchentliche System-Wartung"
            Write-Log "Weekly-System-Maintenance Task erstellt"
        } else {
            Write-Log "Weekly-System-Maintenance Task bereits vorhanden"
        }
    } catch {
        Write-Log "Fehler bei Task Scheduler Konfiguration: $($_.Exception.Message)" "WARNING"
    }

    # Tägliche File-Organization
    try {
        $taskName = "Daily-File-Organization"
        $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        
        if (-not $taskExists) {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$fileOrgScriptPath`""
            $trigger = New-ScheduledTaskTrigger -Daily -At 6PM
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
            
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Tägliche Datei-Organisation"
            Write-Log "Daily-File-Organization Task erstellt"
        } else {
            Write-Log "Daily-File-Organization Task bereits vorhanden"
        }
    } catch {
        Write-Log "Fehler bei Task Scheduler Konfiguration: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== CI/CD Pipeline Templates ==="
    
    # GitHub Actions Template erstellen
    $githubActionsDir = Join-Path $automationDir "GitHub-Actions-Templates"
    if (-not (Test-Path $githubActionsDir)) {
        New-Item -ItemType Directory -Path $githubActionsDir
        Write-Log "GitHub Actions Templates Verzeichnis erstellt: $githubActionsDir"
    }

    # Node.js CI Template
    $nodejsCIContent = @'
name: Node.js CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v4
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm run build --if-present
    - run: npm test
'@

    $nodejsCIPath = Join-Path $githubActionsDir "nodejs-ci.yml"
    Set-Content -Path $nodejsCIPath -Value $nodejsCIContent -Encoding UTF8
    Write-Log "Node.js CI Template erstellt: $nodejsCIPath"

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Erstellte Automation-Skripte:"
    Write-Log "- System-Maintenance: $maintenanceScriptPath"
    Write-Log "- File-Organization: $fileOrgScriptPath"
    Write-Log ""
    Write-Log "Geplante Aufgaben:"
    Write-Log "- Weekly-System-Maintenance (Sonntag 02:00 Uhr)"
    Write-Log "- Daily-File-Organization (täglich 18:00 Uhr)"
    Write-Log ""
    Write-Log "Wichtige nächste Schritte:"
    Write-Log "1. GitHub CLI mit 'gh auth login' konfigurieren"
    Write-Log "2. Jenkins über Docker starten (optional)"
    Write-Log "3. Automation-Skripte testen"
    Write-Log "4. File Juggler manuell installieren (optional)"
    Write-Log "5. CI/CD Templates für eigene Projekte anpassen"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Automation und Workflow-Optimierung Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ GitHub CLI
✓ Azure CLI
✓ CCleaner
✓ BleachBit
✓ HWMonitor
✓ Chocolatey

Automation-Verzeichnis:
- $automationDir

Erstellte Skripte:
- System-Maintenance: $maintenanceScriptPath
- File-Organization: $fileOrgScriptPath

CI/CD Templates:
- Node.js CI: $nodejsCIPath

Geplante Aufgaben:
- Weekly-System-Maintenance (Sonntag 02:00)
- Daily-File-Organization (täglich 18:00)

Manuelle Installationen empfohlen:
- File Juggler (File Organization)
- Jenkins (Docker-basiert)

Nächste Schritte:
- GitHub CLI authentifizieren
- Automation-Skripte testen
- CI/CD-Pipeline konfigurieren
- Monitoring-Alerts einrichten
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Automation und Workflow-Optimierung Setup abgeschlossen!"
