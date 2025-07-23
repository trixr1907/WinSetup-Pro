# ===================================================================
# Webserver und Hosting-Umgebung Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Automatisierte Installation von XAMPP, Nginx, PHP und SSL-Tools
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\Webserver-Hosting-Setup.log"
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

Write-Log "=== Webserver und Hosting-Umgebung Setup gestartet ==="

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
    Write-Log "=== XAMPP-Stack Installation ==="
    
    # XAMPP installieren
    Write-Log "Installiere XAMPP..."
    winget install ApacheFriends.Xampp.8.2
    Write-Log "XAMPP installiert"

    Write-Log "=== Nginx als Reverse-Proxy ==="
    
    # Nginx installieren
    Write-Log "Installiere Nginx..."
    winget install nginx.nginx
    Write-Log "Nginx installiert"

    Write-Log "=== PHP und Composer Installation ==="
    
    # PHP installieren (falls nicht in XAMPP enthalten gewünscht)
    Write-Log "Installiere PHP..."
    winget install PHP.PHP
    Write-Log "PHP installiert"

    # Composer installieren
    Write-Log "Installiere Composer..."
    winget install Composer.Composer
    Write-Log "Composer installiert"

    Write-Log "=== SSL-Zertifikat-Tools ==="
    
    # mkcert für lokale SSL-Zertifikate
    Write-Log "Installiere mkcert für lokale SSL-Zertifikate..."
    winget install FiloSottile.mkcert
    Write-Log "mkcert installiert"

    # OpenSSL (falls nicht vorhanden)
    Write-Log "Installiere OpenSSL..."
    winget install ShiningLight.OpenSSL
    Write-Log "OpenSSL installiert"

    Write-Log "=== Zusätzliche Web-Development-Tools ==="
    
    # Local by Flywheel (WordPress lokale Entwicklung)
    Write-Log "Installiere Local by Flywheel..."
    winget install Flywheel.Local
    Write-Log "Local by Flywheel installiert"

    # WAMP Server (Alternative zu XAMPP)
    Write-Log "Installiere WampServer..."
    winget install WampServer.WampServer
    Write-Log "WampServer installiert"

    Write-Log "=== Arbeitsverzeichnisse erstellen ==="
    
    # Web-Projekte Verzeichnis
    $webProjectsDir = "$env:USERPROFILE\WebProjects"
    if (-not (Test-Path $webProjectsDir)) {
        New-Item -ItemType Directory -Path $webProjectsDir
        Write-Log "Web-Projekte Verzeichnis erstellt: $webProjectsDir"
    }

    # SSL-Zertifikate Verzeichnis
    $sslCertsDir = "$env:USERPROFILE\SSL-Certificates"
    if (-not (Test-Path $sslCertsDir)) {
        New-Item -ItemType Directory -Path $sslCertsDir
        Write-Log "SSL-Zertifikate Verzeichnis erstellt: $sslCertsDir"
    }

    # Apache Virtual Hosts Verzeichnis
    $vhostsDir = "$env:USERPROFILE\Apache-VirtualHosts"
    if (-not (Test-Path $vhostsDir)) {
        New-Item -ItemType Directory -Path $vhostsDir
        Write-Log "Apache Virtual Hosts Verzeichnis erstellt: $vhostsDir"
    }

    Write-Log "=== mkcert Root CA installieren ==="
    
    # mkcert Root CA installieren (für lokale SSL-Zertifikate)
    try {
        mkcert -install
        Write-Log "mkcert Root CA installiert"
    } catch {
        Write-Log "mkcert Root CA Installation fehlgeschlagen: $($_.Exception.Message)" "WARNING"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Wichtige Pfade:"
    Write-Log "- XAMPP Control Panel: Normalerweise C:\xampp\xampp-control.exe"
    Write-Log "- Web-Projekte: $webProjectsDir"
    Write-Log "- SSL-Zertifikate: $sslCertsDir"
    Write-Log "- Virtual Hosts: $vhostsDir"
    Write-Log ""
    Write-Log "Nächste Schritte:"
    Write-Log "1. XAMPP Control Panel starten und Apache/MySQL aktivieren"
    Write-Log "2. Lokale Domains in hosts-Datei eintragen"
    Write-Log "3. Virtual Hosts konfigurieren"
    Write-Log "4. SSL-Zertifikate für Entwicklungsprojekte erstellen"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== Webserver und Hosting-Umgebung Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ XAMPP (Apache, MySQL, PHP, phpMyAdmin)
✓ Nginx
✓ PHP (standalone)
✓ Composer
✓ mkcert (SSL-Zertifikat-Tool)
✓ OpenSSL
✓ Local by Flywheel
✓ WampServer

Arbeitsverzeichnisse:
- Web-Projekte: $webProjectsDir
- SSL-Zertifikate: $sslCertsDir
- Virtual Hosts: $vhostsDir

Nächste Schritte:
- XAMPP Dienste konfigurieren und starten
- Virtual Hosts für Projekte einrichten
- SSL-Zertifikate für lokale Domains generieren
- Local-Domain-Management einrichten
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "Webserver und Hosting-Umgebung Setup abgeschlossen!"
