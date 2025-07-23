# ===================================================================
# HomeAssistant und IoT-Integration Setup Skript
# Erstellt am: 19.07.2025
# Autor: Windows-PostInstall-Setup Projekt
# Beschreibung: Automatisierte Installation von HomeAssistant, IoT-Tools und Smart Home-Management
# ===================================================================

param(
    [switch]$SkipPrompts,
    [switch]$LogOnly,
    [string]$LogPath = "$PSScriptRoot\..\config\HomeAssistant-IoT-Setup.log"
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

Write-Log "=== HomeAssistant und IoT-Integration Setup gestartet ==="

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
    # Node.js prüfen (erforderlich für Node-RED)
    Write-Log "Prüfe Node.js Installation..."
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Log "Node.js bereits installiert: $nodeVersion"
    } else {
        Write-Log "Node.js nicht gefunden. Installiere Node.js..."
        winget install OpenJS.NodeJS.LTS
        Write-Log "Node.js LTS installiert"
    }

    # Python prüfen (erforderlich für ESPHome)
    Write-Log "Prüfe Python Installation..."
    $pythonVersion = python --version 2>$null
    if ($pythonVersion) {
        Write-Log "Python bereits installiert: $pythonVersion"
    } else {
        Write-Log "Python nicht gefunden. Installiere Python..."
        winget install Python.Python.3.12
        Write-Log "Python 3.12 installiert"
    }

    Write-Log "=== HomeAssistant Desktop/Web-Client Setup ==="
    
    # Home Assistant Core über pip (Python erforderlich)
    Write-Log "Installiere Home Assistant Core..."
    pip install homeassistant
    Write-Log "Home Assistant Core installiert"

    Write-Log "=== MQTT-Client für IoT-Kommunikation ==="
    
    # Eclipse Mosquitto MQTT Broker
    Write-Log "Installiere Mosquitto MQTT Broker..."
    winget install EclipseMosquitto.Mosquitto
    Write-Log "Mosquitto MQTT Broker installiert"

    # MQTT Explorer (GUI Client)
    Write-Log "Installiere MQTT Explorer..."
    winget install MQTTX.MQTTX
    Write-Log "MQTT Explorer installiert"

    Write-Log "=== Node-RED Installation (lokale Instanz) ==="
    
    # Node-RED global installieren
    Write-Log "Installiere Node-RED..."
    npm install -g --unsafe-perm node-red
    Write-Log "Node-RED installiert"

    # Node-RED Dashboard
    Write-Log "Installiere Node-RED Dashboard..."
    npm install -g node-red-dashboard
    Write-Log "Node-RED Dashboard installiert"

    Write-Log "=== ESPHome-Tools für ESP-Geräte ==="
    
    # ESPHome über pip installieren
    Write-Log "Installiere ESPHome..."
    pip install esphome
    Write-Log "ESPHome installiert"

    Write-Log "=== YAML-Editor mit HA-Syntax-Highlighting ==="
    
    # VS Code YAML Extension (falls VS Code installiert)
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Log "Installiere VS Code YAML Extension..."
        code --install-extension redhat.vscode-yaml
        code --install-extension vscode-home-assistant.vscode-home-assistant
        Write-Log "VS Code Home Assistant Extensions installiert"
    } else {
        Write-Log "VS Code nicht gefunden. YAML-Extensions übersprungen."
    }

    Write-Log "=== IoT-Device-Discovery-Tools ==="
    
    # Advanced IP Scanner
    Write-Log "Installiere Advanced IP Scanner..."
    winget install Famatech.AdvancedIPScanner
    Write-Log "Advanced IP Scanner installiert"

    # Nmap für Netzwerk-Scanning
    Write-Log "Installiere Nmap..."
    winget install Insecure.Nmap
    Write-Log "Nmap installiert"

    Write-Log "=== Network-Sniffer für IoT-Debugging ==="
    
    # Wireshark für Netzwerk-Analyse
    Write-Log "Installiere Wireshark..."
    winget install WiresharkFoundation.Wireshark
    Write-Log "Wireshark installiert"

    Write-Log "=== Zusätzliche IoT-Tools ==="
    
    # Putty für SSH-Verbindungen zu IoT-Geräten
    Write-Log "Installiere PuTTY..."
    winget install PuTTY.PuTTY
    Write-Log "PuTTY installiert"

    # Erstelle HomeAssistant Arbeitsverzeichnis
    $haWorkDir = "$env:USERPROFILE\HomeAssistant"
    if (-not (Test-Path $haWorkDir)) {
        New-Item -ItemType Directory -Path $haWorkDir
        Write-Log "HomeAssistant Arbeitsverzeichnis erstellt: $haWorkDir"
    }

    # Erstelle Node-RED Arbeitsverzeichnis
    $nodeRedDir = "$env:USERPROFILE\.node-red"
    if (-not (Test-Path $nodeRedDir)) {
        New-Item -ItemType Directory -Path $nodeRedDir
        Write-Log "Node-RED Arbeitsverzeichnis erstellt: $nodeRedDir"
    }

    Write-Log "=== Setup erfolgreich abgeschlossen ==="
    Write-Log ""
    Write-Log "Nächste Schritte:"
    Write-Log "1. Home Assistant starten: 'hass' im Terminal"
    Write-Log "2. Node-RED starten: 'node-red' im Terminal"
    Write-Log "3. MQTT Broker starten: Mosquitto Service prüfen"
    Write-Log "4. Konfigurationsdateien in $haWorkDir bearbeiten"
    Write-Log ""
    Write-Log "Wichtige URLs nach dem Start:"
    Write-Log "- Home Assistant: http://localhost:8123"
    Write-Log "- Node-RED: http://localhost:1880"
    Write-Log ""

    # Status-Update
    $computerName = $env:COMPUTERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $statusUpdate = @"
=== HomeAssistant und IoT-Integration Setup Abgeschlossen ===
Computer: $computerName
Konfiguriert am: $timestamp

Installierte Software:
✓ Home Assistant Core
✓ Mosquitto MQTT Broker
✓ MQTT Explorer (MQTTX)
✓ Node-RED mit Dashboard
✓ ESPHome
✓ VS Code Home Assistant Extensions
✓ Advanced IP Scanner
✓ Nmap
✓ Wireshark
✓ PuTTY

Arbeitsverzeichnisse:
- HomeAssistant: $haWorkDir
- Node-RED: $nodeRedDir

Nächste Schritte:
- Zigbee/Z-Wave USB-Dongle-Treiber installieren
- IoT-Geräte-Inventar erstellen
- Automatisierungsregeln konfigurieren
"@

    Add-Content -Path $LogPath -Value $statusUpdate
    Write-Log "Setup-Details in Log-Datei gespeichert: $LogPath"

} catch {
    Write-Log "Fehler während der Installation: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}

Write-Log "HomeAssistant und IoT-Integration Setup abgeschlossen!"
