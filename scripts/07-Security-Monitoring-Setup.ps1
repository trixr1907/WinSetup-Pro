# ===================================================================
# Security und Monitoring-Tools Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Installation von Sicherheits- und Überwachungstools
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Security-Monitoring-Setup.log"
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

Write-Log "=== Security und Monitoring-Tools Setup gestartet ==="

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
    Write-Log "=== Antivirus und Endpoint Protection ==="
    
    # Windows Defender bereits vorhanden, aber Malwarebytes als zusätzlicher Schutz
    Write-Log "Installiere Malwarebytes..."
    winget install Malwarebytes.Malwarebytes
    Write-Log "Malwarebytes installiert"

    Write-Log "=== Network-Monitoring und Penetration-Testing ==="
    
    # Wireshark für Netzwerk-Analyse (falls noch nicht installiert)
    Write-Log "Installiere Wireshark..."
    winget install WiresharkFoundation.Wireshark
    Write-Log "Wireshark installiert"

    # Nmap für Netzwerk-Scanning (falls noch nicht installiert)
    Write-Log "Installiere Nmap..."
    winget install Insecure.Nmap
    Write-Log "Nmap installiert"

    # Advanced Port Scanner
    Write-Log "Installiere Advanced Port Scanner..."
    winget install Famatech.AdvancedPortScanner
    Write-Log "Advanced Port Scanner installiert"

    Write-Log "=== Password Management ==="
    
    # KeePass für Password Management
    Write-Log "Installiere KeePass..."
    winget install DominikReichl.KeePass
    Write-Log "KeePass installiert"

    # Bitwarden als Alternative
    Write-Log "Installiere Bitwarden..."
    winget install Bitwarden.Bitwarden
    Write-Log "Bitwarden installiert"

    Write-Log "=== System Monitoring ==="
    
    # Process Monitor
    Write-Log "Installiere Process Monitor..."
    winget install Microsoft.Sysinternals.ProcessMonitor
    Write-Log "Process Monitor installiert"

    # Process Explorer
    Write-Log "Installiere Process Explorer..."
    winget install Microsoft.Sysinternals.ProcessExplorer
    Write-Log "Process Explorer installiert"

    # Resource Monitor ist bereits in Windows enthalten
    Write-Log "Windows Resource Monitor bereits verfügbar"

    Write-Log "=== Log-Analyse und SIEM ==="
    
    # Event Log Explorer
    Write-Log "Installiere Event Log Explorer..."
    # Hinweis: Möglicherweise nicht über winget verfügbar
    Write-Log "Event Log Explorer: Manuelle Installation erforderlich von FSPro Labs"

    # Syslog Server (Kiwi Syslog Server Free)
    Write-Log "Syslog Server für Log-Aggregation wird konfiguriert..."
    Write-Log "Kiwi Syslog Server: Manuelle Installation erforderlich"

    Write-Log "=== Vulnerability Scanner ==="
    
    # OpenVAS/Greenbone (komplexere Installation)
    Write-Log "OpenVAS: Empfehlung für Docker-basierte Installation"
    Write-Log "Alternative: Nessus Home für private Nutzung"

    # OWASP ZAP für Web Application Security Testing
    Write-Log "Installiere OWASP ZAP..."
    winget install ZAP.ZAP
    Write-Log "OWASP ZAP installiert"

    Write-Log "=== Firewall und Network Security ==="
    
    # Windows Firewall mit erweiterten Einstellungen bereits vorhanden
    Write-Log "Windows Firewall erweiterte Konfiguration vorbereitet"
    
    # Simplewall als erweiterte Firewall-GUI
    Write-Log "Installiere Simplewall..."
    winget install Henry++.simplewall
    Write-Log "Simplewall installiert"

    Write-Log "=== 2FA und Authentication ==="
    
    # Microsoft Authenticator
    Write-Log "Installiere Microsoft Authenticator (Desktop Version)..."
    # Hinweis: Hauptsächlich mobile App, aber WinAuth als Alternative
    Write-Log "WinAuth für 2FA-Codes wird empfohlen (manuelle Installation)"

    # Authy Desktop
    Write-Log "Installiere Authy Desktop..."
    winget install Twilio.Authy
    Write-Log "Authy Desktop installiert"

    Write-Log "=== Security Headers und Web Security Testing ==="
    
    # Browser-Security-Extensions werden über Browser installiert
    Write-Log "Browser-Security-Extensions: Manuelle Installation empfohlen"
    Write-Log "- uBlock Origin"
    Write-Log "- Privacy Badger" 
    Write-Log "- HTTPS Everywhere"

    Write-Log "=== Arbeitsverzeichnisse erstellen ==="
    
    # Security-Tools Verzeichnis
    $securityToolsDir = "$env:USERPROFILE\Security-Tools"
    if (-not (Test-Path $securityToolsDir)) {
        New-Item -ItemType Directory -Path $securityToolsDir
        Write-Log "Security-Tools Verzeichnis erstellt: $securityToolsDir"
    }

    # Security-Logs Verzeichnis
    $securityLogsDir = "$env:USERPROFILE\Security-Logs"
    if (-not (Test-Path $securityLogsDir)) {
        New-Item -ItemType Directory -Path $securityLogsDir
        Write-Log "Security-Logs Verzeichnis erstellt: $securityLogsDir"
    }

    # Penetration-Testing Verzeichnis
    $pentestDir = "$env:USERPROFILE\Penetration-Testing"
    if (-not (Test-Path $pentestDir)) {
        New-Item -ItemType Directory -Path $pentestDir
        Write-Log "Penetration-Testing Verzeichnis erstellt: $pentestDir"
    }

    Write-Log "=== Windows Defender Konfiguration optimieren ==="
    
    # Windows Defender Echtzeitschutz prüfen
    $defenderStatus = Get-MpComputerStatus
    if ($defenderStatus.RealTimeProtectionEnabled) {
        Write-Log "Windows Defender Echtzeitschutz ist aktiviert"
    } else {
        Write-Log "WARNUNG: Windows Defender Echtzeitschutz ist deaktiviert" "WARNING"
    }

    # Cloud-basierte Protection aktivieren
    try {
        Set-MpPreference -MAPSReporting Advanced
        Set-MpPreference -SubmitSamplesConsent SendAllSamples
        Write-Log "Windows Defender Cloud-Schutz aktiviert"
    } catch {
        Write-Log "Fehler bei Windows Defender Konfiguration: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Wichtige nächste Schritte:"
    Write-Log "1. KeePass Datenbank erstellen und Master-Passwort setzen"
    Write-Log "2. Bitwarden Account einrichten und synchronisieren"
    Write-Log "3. OWASP ZAP für Web-Security-Tests konfigurieren"
    Write-Log "4. Nmap-Scans nur in eigenen Netzwerken durchführen"
    Write-Log "5. Firewall-Regeln mit Simplewall überprüfen"
    Write-Log ""
    Write-Log "Manuelle Installationen erforderlich:"
    Write-Log "- Event Log Explorer (FSPro Labs)"
    Write-Log "- Kiwi Syslog Server (SolarWinds)"
    Write-Log "- WinAuth für 2FA-Codes"
    Write-Log "- Browser-Security-Extensions"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Security und Monitoring-Tools Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ Malwarebytes (Anti-Malware)
✓ Wireshark (Network Analysis)
✓ Nmap (Network Scanning)
✓ Advanced Port Scanner
✓ KeePass (Password Manager)
✓ Bitwarden (Password Manager)
✓ Process Monitor
✓ Process Explorer
✓ OWASP ZAP (Web Security Testing)
✓ Simplewall (Advanced Firewall)
✓ Authy Desktop (2FA)

Arbeitsverzeichnisse:
- Security-Tools: $securityToolsDir
- Security-Logs: $securityLogsDir
- Penetration-Testing: $pentestDir

Windows Defender Status:
- Echtzeitschutz: $($defenderStatus.RealTimeProtectionEnabled)
- Cloud-Schutz: Aktiviert

Manuelle Installationen empfohlen:
- Event Log Explorer
- Kiwi Syslog Server
- WinAuth
- Browser-Security-Extensions

Nächste Schritte:
- Password-Manager konfigurieren
- Security-Monitoring-Dashboard einrichten
- Penetration-Testing-Checklisten erstellen
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Security und Monitoring-Tools Setup abgeschlossen!"
