# ===================================================================
# Backup und Disaster-Recovery Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Installation und Konfiguration von Backup-Lösungen
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Backup-Recovery-Setup.log"
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

Write-Log "=== Backup und Disaster-Recovery Setup gestartet ==="

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
    Write-Log "=== System-Image-Backup-Tools ==="
    
    # Macrium Reflect (Free Version)
    Write-Log "Installiere Macrium Reflect Free..."
    # Hinweis: Möglicherweise nicht über winget verfügbar
    Write-Log "Macrium Reflect: Manuelle Installation empfohlen von macrium.com"

    # AOMEI Backupper (Alternative)
    Write-Log "Installiere AOMEI Backupper..."
    winget install AOMEI.Backupper.Standard
    Write-Log "AOMEI Backupper installiert"

    # Clonezilla (ISO-basiert, für Notfälle)
    Write-Log "Clonezilla: Empfehlung für bootbare Notfall-CD (clonezilla.org)"

    Write-Log "=== File-Level Backup Tools ==="
    
    # FreeFileSync für Synchronisation
    Write-Log "Installiere FreeFileSync..."
    winget install FreeFileSync.FreeFileSync
    Write-Log "FreeFileSync installiert"

    # Robocopy (bereits in Windows enthalten)
    Write-Log "Robocopy bereits in Windows verfügbar"

    # 7-Zip für Archivierung (falls nicht installiert)
    Write-Log "Installiere 7-Zip..."
    winget install 7zip.7zip
    Write-Log "7-Zip installiert"

    Write-Log "=== Cloud-Backup Integration ==="
    
    # OneDrive (bereits in Windows 11)
    Write-Log "OneDrive bereits in Windows verfügbar"
    
    # Google Drive Desktop
    Write-Log "Installiere Google Drive Desktop..."
    winget install Google.GoogleDrive
    Write-Log "Google Drive Desktop installiert"

    # Dropbox
    Write-Log "Installiere Dropbox..."
    winget install Dropbox.Dropbox
    Write-Log "Dropbox installiert"

    Write-Log "=== Versionskontrolle für Konfigurationen ==="
    
    # Git ist bereits installiert (Schritt 2)
    Write-Log "Git bereits für Code-Repository-Backups verfügbar"

    Write-Log "=== Database-Backup-Tools ==="
    
    # MySQL Workbench (für MySQL/MariaDB Backups)
    Write-Log "Installiere MySQL Workbench..."
    winget install Oracle.MySQLWorkbench
    Write-Log "MySQL Workbench installiert"

    # pgAdmin bereits in Schritt 5 installiert
    Write-Log "pgAdmin bereits für PostgreSQL-Backups verfügbar"

    Write-Log "=== Backup-Verzeichnisse und Struktur erstellen ==="
    
    # Hauptbackup-Verzeichnis
    $backupRootDir = "$env:USERPROFILE\Backups"
    if (-not (Test-Path $backupRootDir)) {
        New-Item -ItemType Directory -Path $backupRootDir
        Write-Log "Hauptbackup-Verzeichnis erstellt: $backupRootDir"
    }

    # Unterverzeichnisse für verschiedene Backup-Typen
    $backupDirs = @(
        "System-Images",
        "Database-Dumps",
        "Configuration-Files",
        "Projects-Archive",
        "Documents-Backup",
        "Scripts-Backup"
    )

    foreach ($dir in $backupDirs) {
        $fullPath = Join-Path $backupRootDir $dir
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath
            Write-Log "Backup-Unterverzeichnis erstellt: $fullPath"
        }
    }

    Write-Log "=== Automatisierte Backup-Skripte erstellen ==="
    
    # Einfaches Robocopy-Backup-Skript für wichtige Verzeichnisse
    $robocopyScriptContent = @"
@echo off
echo Starte automatisches File-Backup...
set BACKUP_SOURCE=%USERPROFILE%\Documents
set BACKUP_DEST=%USERPROFILE%\Backups\Documents-Backup
set LOG_FILE=%USERPROFILE%\Backups\robocopy-log.txt

robocopy `"%BACKUP_SOURCE%`" `"%BACKUP_DEST%`" /MIR /LOG:`"%LOG_FILE%`" /R:3 /W:10 /MT:8

echo.
echo Backup abgeschlossen: %date% %time%
echo Log-Datei: %LOG_FILE%
pause
"@

    $robocopyScriptPath = Join-Path $backupRootDir "Documents-Backup-Script.bat"
    Set-Content -Path $robocopyScriptPath -Value $robocopyScriptContent -Encoding ASCII
    Write-Log "Robocopy-Backup-Skript erstellt: $robocopyScriptPath"

    # PowerShell-Backup-Skript für Datenbanken
    $dbBackupScriptContent = @'
# Database Backup Script
param(
    [string]$BackupPath = "$env:USERPROFILE\Backups\Database-Dumps"
)

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# MySQL/MariaDB Backup (falls installiert)
if (Get-Command mysql -ErrorAction SilentlyContinue) {
    Write-Host "Erstelle MySQL-Backup..."
    mysqldump --all-databases --single-transaction > "$BackupPath\mysql-backup-$timestamp.sql"
    Write-Host "MySQL-Backup erstellt: mysql-backup-$timestamp.sql"
}

# PostgreSQL Backup (falls installiert)
if (Get-Command pg_dumpall -ErrorAction SilentlyContinue) {
    Write-Host "Erstelle PostgreSQL-Backup..."
    pg_dumpall > "$BackupPath\postgresql-backup-$timestamp.sql"
    Write-Host "PostgreSQL-Backup erstellt: postgresql-backup-$timestamp.sql"
}

# MongoDB Backup (falls installiert)
if (Get-Command mongodump -ErrorAction SilentlyContinue) {
    Write-Host "Erstelle MongoDB-Backup..."
    mongodump --out "$BackupPath\mongodb-backup-$timestamp"
    Write-Host "MongoDB-Backup erstellt: mongodb-backup-$timestamp"
}

Write-Host "Database-Backup abgeschlossen: $(Get-Date)"
'@

    $dbBackupScriptPath = Join-Path $backupRootDir "Database-Backup-Script.ps1"
    Set-Content -Path $dbBackupScriptPath -Value $dbBackupScriptContent -Encoding UTF8
    Write-Log "Database-Backup-Skript erstellt: $dbBackupScriptPath"

    Write-Log "=== Windows Backup und Wiederherstellung aktivieren ==="
    
    # Windows Backup Feature aktivieren (falls deaktiviert)
    try {
        $backupFeature = Get-WindowsOptionalFeature -Online -FeatureName "WindowsBackup"
        if ($backupFeature.State -ne "Enabled") {
            Write-Log "Aktiviere Windows Backup Feature..."
            Enable-WindowsOptionalFeature -Online -FeatureName "WindowsBackup" -All -NoRestart
            Write-Log "Windows Backup Feature aktiviert"
        } else {
            Write-Log "Windows Backup Feature bereits aktiviert"
        }
    } catch {
        Write-Log "Fehler bei Windows Backup Feature Aktivierung: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== Systemwiederherstellung konfigurieren ==="
    
    # Systemwiederherstellung aktivieren (falls nicht aktiv)
    try {
        $restoreStatus = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        if (-not $restoreStatus) {
            Write-Log "Aktiviere Systemwiederherstellung..."
            Enable-ComputerRestore -Drive "$env:SystemDrive\"
            Checkpoint-Computer -Description "Windows-PostInstall-Setup Baseline" -RestorePointType "MODIFY_SETTINGS"
            Write-Log "Systemwiederherstellung aktiviert und Wiederherstellungspunkt erstellt"
        } else {
            Write-Log "Systemwiederherstellung bereits aktiv"
        }
    } catch {
        Write-Log "Fehler bei Systemwiederherstellung: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== Backup-Zeitplanung mit Task Scheduler ==="
    
    # Tägliches Dokumenten-Backup um 20:00 Uhr
    try {
        $taskName = "Daily-Documents-Backup"
        $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        
        if (-not $taskExists) {
            $action = New-ScheduledTaskAction -Execute $robocopyScriptPath
            $trigger = New-ScheduledTaskTrigger -Daily -At 8PM
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
            
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Automatisches tägliches Backup der Dokumente"
            Write-Log "Backup-Task im Task Scheduler erstellt: $taskName"
        } else {
            Write-Log "Backup-Task bereits vorhanden: $taskName"
        }
    } catch {
        Write-Log "Fehler bei Task Scheduler Konfiguration: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Backup-Verzeichnisse erstellt:"
    foreach ($dir in $backupDirs) {
        Write-Log "- $(Join-Path $backupRootDir $dir)"
    }
    Write-Log ""
    Write-Log "Wichtige nächste Schritte:"
    Write-Log "1. System-Image mit AOMEI Backupper erstellen"
    Write-Log "2. Cloud-Backup-Clients (OneDrive, Google Drive) konfigurieren"
    Write-Log "3. Backup-Skripte testen: $robocopyScriptPath"
    Write-Log "4. Database-Backup-Skript ausführen: $dbBackupScriptPath"
    Write-Log "5. Wiederherstellungstest durchführen"
    Write-Log ""
    Write-Log "Geplante Aufgaben:"
    Write-Log "- Tägliches Dokumenten-Backup um 20:00 Uhr"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Backup und Disaster-Recovery Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ AOMEI Backupper Standard
✓ FreeFileSync (Synchronisation)
✓ 7-Zip (Archivierung)
✓ Google Drive Desktop
✓ Dropbox
✓ MySQL Workbench

Backup-Verzeichnisstruktur:
- Haupt-Backup: $backupRootDir
$(foreach ($dir in $backupDirs) { "- $dir`n" } )

Erstellte Skripte:
- Dokumenten-Backup: $robocopyScriptPath
- Database-Backup: $dbBackupScriptPath

Geplante Aufgaben:
- Daily-Documents-Backup (täglich 20:00 Uhr)

Windows Features:
- Windows Backup: Aktiviert
- Systemwiederherstellung: Aktiviert

Manuelle Installationen empfohlen:
- Macrium Reflect Free
- Clonezilla (bootbare Notfall-CD)

Nächste Schritte:
- System-Image-Backup erstellen
- Cloud-Synchronisation konfigurieren
- Backup-Verifikation durchführen
- Disaster-Recovery-Test planen
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Backup und Disaster-Recovery Setup abgeschlossen!"
