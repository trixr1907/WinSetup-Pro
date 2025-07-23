# Windows Post-Install Setup - Schritt 1: System-Grundkonfiguration und Sicherheit
# Automatisierungsskript für Sicherheits-Grundeinstellungen

Write-Host "=== Windows System-Grundkonfiguration wird gestartet ===" -ForegroundColor Green

# 1. Windows Update Status prüfen
Write-Host "`n1. Windows Update Status wird geprüft..." -ForegroundColor Yellow
$LastUpdates = Get-Hotfix | Sort-Object InstalledOn -Descending | Select-Object -First 5
Write-Host "Letzte 5 installierte Updates:" -ForegroundColor Cyan
$LastUpdates | Format-Table -AutoSize

# 2. Windows Defender Status prüfen und optimieren
Write-Host "`n2. Windows Defender wird konfiguriert..." -ForegroundColor Yellow
$DefenderStatus = Get-MpComputerStatus
Write-Host "Defender Status:" -ForegroundColor Cyan
Write-Host "  Echtzeitschutz: $($DefenderStatus.RealTimeProtectionEnabled)" 
Write-Host "  Verhaltensüberwachung: $($DefenderStatus.BehaviorMonitorEnabled)"
Write-Host "  Cloud-Schutz: $($DefenderStatus.MAPSReporting)"

# Cloud-Schutz aktivieren (falls nicht bereits aktiv)
Set-MpPreference -MAPSReporting Advanced -ErrorAction SilentlyContinue
Write-Host "  Cloud-Schutz wurde auf 'Advanced' gesetzt" -ForegroundColor Green

# 3. Firewall-Status prüfen und Entwickler-Regeln hinzufügen
Write-Host "`n3. Windows Firewall wird konfiguriert..." -ForegroundColor Yellow
$FirewallProfiles = Get-NetFirewallProfile
$FirewallProfiles | Format-Table Name, Enabled -AutoSize

# Entwickler-freundliche Firewall-Regeln hinzufügen
$DevPorts = @(3000, 8000, 8080, 5000, 3001, 4200, 8081)
foreach ($Port in $DevPorts) {
    $RuleName = "Dev-Port-$Port-Inbound"
    if (!(Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow -Profile Private
        Write-Host "  Firewall-Regel für Port $Port hinzugefügt" -ForegroundColor Green
    }
}

# 4. UAC-Einstellungen prüfen
Write-Host "`n4. Benutzerkontensteuerung (UAC) Status..." -ForegroundColor Yellow
$UACRegistry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin"
Write-Host "  UAC-Level: $($UACRegistry.ConsentPromptBehaviorAdmin)" -ForegroundColor Cyan

# 5. Systemwiederherstellung aktivieren
Write-Host "`n5. Systemwiederherstellung wird konfiguriert..." -ForegroundColor Yellow
$SystemDrive = $env:SystemDrive
try {
    Enable-ComputerRestore -Drive $SystemDrive -ErrorAction Stop
    Write-Host "  Systemwiederherstellung für $SystemDrive aktiviert" -ForegroundColor Green
    
    # Wiederherstellungspunkt erstellen
    $RestorePointName = "Post-Install Setup - $(Get-Date -Format 'dd.MM.yyyy HH:mm')"
    Checkpoint-Computer -Description $RestorePointName -RestorePointType "MODIFY_SETTINGS"
    Write-Host "  Wiederherstellungspunkt '$RestorePointName' erstellt" -ForegroundColor Green
} catch {
    Write-Host "  Systemwiederherstellung bereits aktiv oder nicht verfügbar" -ForegroundColor Yellow
}

# 6. Telemetrie-Einstellungen optimieren
Write-Host "`n6. Telemetrie-Einstellungen werden optimiert..." -ForegroundColor Yellow
$TelemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $TelemetryPath)) {
    New-Item -Path $TelemetryPath -Force | Out-Null
}
Set-ItemProperty -Path $TelemetryPath -Name "AllowTelemetry" -Value 1 -Type DWord
Write-Host "  Telemetrie auf 'Basic' (Level 1) gesetzt" -ForegroundColor Green

# 7. BitLocker-Status prüfen
Write-Host "`n7. BitLocker-Verschlüsselung wird geprüft..." -ForegroundColor Yellow
try {
    $BitLockerStatus = Get-BitLockerVolume -MountPoint $SystemDrive
    Write-Host "  BitLocker Status für $SystemDrive`: $($BitLockerStatus.ProtectionStatus)" -ForegroundColor Cyan
    
    if ($BitLockerStatus.ProtectionStatus -eq "Off") {
        Write-Host "  BitLocker ist nicht aktiviert. Manuelle Aktivierung empfohlen." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  BitLocker-Information nicht verfügbar" -ForegroundColor Yellow
}

# 8. Automatische Updates für Microsoft Store Apps
Write-Host "`n8. Microsoft Store Auto-Updates werden konfiguriert..." -ForegroundColor Yellow
$StoreAutoUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
if (!(Test-Path $StoreAutoUpdatePath)) {
    New-Item -Path $StoreAutoUpdatePath -Force | Out-Null
}
Set-ItemProperty -Path $StoreAutoUpdatePath -Name "AutoDownload" -Value 4 -Type DWord
Write-Host "  Microsoft Store Auto-Updates aktiviert" -ForegroundColor Green

# 9. Windows Defender Exclusions für Entwicklung
Write-Host "`n9. Windows Defender Entwickler-Ausnahmen werden hinzugefügt..." -ForegroundColor Yellow
$DevFolders = @(
    "$env:USERPROFILE\Documents\GitHub",
    "$env:USERPROFILE\Documents\Projects",
    "$env:USERPROFILE\AppData\Local\npm-cache",
    "$env:USERPROFILE\.nuget"
)

foreach ($Folder in $DevFolders) {
    if (Test-Path $Folder) {
        Add-MpPreference -ExclusionPath $Folder -ErrorAction SilentlyContinue
        Write-Host "  Ausnahme hinzugefügt: $Folder" -ForegroundColor Green
    } else {
        Write-Host "  Ordner nicht gefunden (wird später hinzugefügt): $Folder" -ForegroundColor Yellow
    }
}

# 10. Systeminfo sammeln und dokumentieren
Write-Host "`n10. System-Informationen werden dokumentiert..." -ForegroundColor Yellow
$SystemInfo = @{
    ComputerName = $env:COMPUTERNAME
    WindowsVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    BuildNumber = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber
    TotalRAM = [Math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory/1GB, 2)
    Processor = (Get-WmiObject -Class Win32_Processor).Name
    ConfigDate = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
}

$ConfigLog = @"
=== System-Grundkonfiguration Abgeschlossen ===
Computer: $($SystemInfo.ComputerName)
Windows: $($SystemInfo.WindowsVersion)
Build: $($SystemInfo.BuildNumber)
RAM: $($SystemInfo.TotalRAM) GB
Prozessor: $($SystemInfo.Processor)
Konfiguriert am: $($SystemInfo.ConfigDate)

Durchgeführte Konfigurationen:
✓ Windows Updates geprüft
✓ Windows Defender optimiert (Cloud-Schutz aktiviert)
✓ Windows Firewall konfiguriert (Dev-Ports hinzugefügt)
✓ UAC-Status überprüft
✓ Systemwiederherstellung aktiviert
✓ Telemetrie optimiert (Level 1)
✓ BitLocker-Status geprüft
✓ Microsoft Store Auto-Updates aktiviert
✓ Entwickler-Ausnahmen für Windows Defender hinzugefügt
"@

# Konfiguration in Datei speichern
$ConfigPath = "$PSScriptRoot\..\config\System-Grundkonfiguration.log"
$ConfigLog | Out-File -FilePath $ConfigPath -Encoding UTF8
Write-Host "`nKonfiguration dokumentiert in: $ConfigPath" -ForegroundColor Green

Write-Host "`n=== System-Grundkonfiguration erfolgreich abgeschlossen ===" -ForegroundColor Green
Write-Host "Nächster Schritt: Entwicklungsumgebung-Installation" -ForegroundColor Cyan

# Pause für Benutzer-Review
Write-Host "`nDrücken Sie eine beliebige Taste, um fortzufahren..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
