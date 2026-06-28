# ===================================================================
# System-Validierung aller installierten Tools
# Erstellt am: 20.07.2025
# Beschreibung: Prüft Funktionalität aller installierten Software-Pakete
# ===================================================================

param(
    [switch]$Detailed,
    [string]$LogPath = "$PSScriptRoot\..\config\System-Validation.log"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(if($Level -eq "ERROR"){"Red"} elseif($Level -eq "SUCCESS"){"Green"} elseif($Level -eq "WARNING"){"Yellow"} else{"White"})
    Add-Content -Path $LogPath -Value $logEntry
}

function Test-Command {
    param([string]$Command, [string]$Name)
    try {
        $result = Get-Command $Command -ErrorAction SilentlyContinue
        if ($result) {
            Write-Log "✅ $Name - Verfügbar ($(Split-Path $result.Source -Leaf))" "SUCCESS"
            return $true
        } else {
            Write-Log "❌ $Name - Nicht gefunden" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ $Name - Fehler beim Testen" "ERROR"
        return $false
    }
}

function Test-Service {
    param([string]$ServiceName, [string]$DisplayName)
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            $status = $service.Status
            if ($status -eq "Running") {
                Write-Log "✅ $DisplayName Service - Läuft" "SUCCESS"
            } else {
                Write-Log "⚠️ $DisplayName Service - Status: $status" "WARNING"
            }
            return $true
        } else {
            Write-Log "❌ $DisplayName Service - Nicht gefunden" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ $DisplayName Service - Fehler beim Prüfen" "ERROR"
        return $false
    }
}

Write-Log "=== System-Validierung gestartet ==="
Write-Log "Computer: $env:COMPUTERNAME"
Write-Log "Benutzer: $env:USERNAME"
Write-Log "Datum: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log ""

$validationResults = @{
    "Successful" = 0
    "Failed" = 0
    "Warnings" = 0
}

# Entwicklungstools prüfen
Write-Log "=== Entwicklungstools Validierung ===" "INFO"
$tools = @(
    @{Command="git"; Name="Git"}
    @{Command="node"; Name="Node.js"}
    @{Command="npm"; Name="NPM"}
    @{Command="code"; Name="VS Code"}
    @{Command="docker"; Name="Docker"}
    @{Command="kubectl"; Name="Kubernetes CLI"}
    @{Command="terraform"; Name="Terraform"}
    @{Command="vagrant"; Name="Vagrant"}
)

foreach ($tool in $tools) {
    if (Test-Command $tool.Command $tool.Name) {
        $validationResults.Successful++
    } else {
        $validationResults.Failed++
    }
}

# Datenbank-Tools prüfen
Write-Log "`n=== Datenbank-Tools Validierung ===" "INFO"
$dbTools = @(
    @{Command="mysql"; Name="MySQL/MariaDB"}
    @{Command="psql"; Name="PostgreSQL"}
    @{Command="mongosh"; Name="MongoDB Shell"}
)

foreach ($tool in $dbTools) {
    if (Test-Command $tool.Command $tool.Name) {
        $validationResults.Successful++
    } else {
        $validationResults.Failed++
    }
}

# Services prüfen
Write-Log "`n=== System-Services Validierung ===" "INFO"
$services = @(
    @{Service="MSSQLSERVER"; Name="SQL Server"}
    @{Service="MySQL80"; Name="MySQL"}
    @{Service="postgresql-x64-17"; Name="PostgreSQL"}
    @{Service="MongoDB"; Name="MongoDB"}
)

foreach ($svc in $services) {
    if (Test-Service $svc.Service $svc.Name) {
        # Service exists, result already logged
    }
}

# Windows Features prüfen
Write-Log "`n=== Windows Features Validierung ===" "INFO"
$features = @(
    "Microsoft-Hyper-V-All",
    "IIS-WebServerRole",
    "Microsoft-Windows-Subsystem-Linux"
)

foreach ($feature in $features) {
    try {
        $feat = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
        if ($feat) {
            if ($feat.State -eq "Enabled") {
                Write-Log "✅ Windows Feature: $feature - Aktiviert" "SUCCESS"
                $validationResults.Successful++
            } else {
                Write-Log "⚠️ Windows Feature: $feature - Deaktiviert" "WARNING"
                $validationResults.Warnings++
            }
        }
    } catch {
        Write-Log "❌ Windows Feature: $feature - Nicht verfügbar" "ERROR"
        $validationResults.Failed++
    }
}

# Verzeichnisse prüfen
Write-Log "`n=== Projektverzeichnisse Validierung ===" "INFO"
$directories = @(
    "$env:USERPROFILE\Development",
    "$env:USERPROFILE\Database-Backups", 
    "$env:USERPROFILE\VM-Backups",
    "$PSScriptRoot\..\config",
    "$PSScriptRoot\..\scripts"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Log "✅ Verzeichnis: $(Split-Path $dir -Leaf) - Existiert" "SUCCESS"
        $validationResults.Successful++
    } else {
        Write-Log "❌ Verzeichnis: $(Split-Path $dir -Leaf) - Fehlt" "ERROR"
        $validationResults.Failed++
    }
}

# Zusammenfassung
Write-Log "`n=== VALIDIERUNGS-ZUSAMMENFASSUNG ===" "INFO"
Write-Log "✅ Erfolgreich: $($validationResults.Successful)" "SUCCESS"
Write-Log "⚠️ Warnungen: $($validationResults.Warnings)" "WARNING"  
Write-Log "❌ Fehlgeschlagen: $($validationResults.Failed)" "ERROR"

$totalTests = $validationResults.Successful + $validationResults.Failed + $validationResults.Warnings
$successRate = [math]::Round(($validationResults.Successful / $totalTests) * 100, 1)

Write-Log "📊 Erfolgsrate: $successRate%" "INFO"

if ($validationResults.Failed -eq 0) {
    Write-Log "🎉 System vollständig funktionsfähig!" "SUCCESS"
} elseif ($validationResults.Failed -le 3) {
    Write-Log "⚠️ System größtenteils funktionsfähig - Kleinere Probleme vorhanden" "WARNING"
} else {
    Write-Log "❌ System benötigt Nacharbeit - Mehrere kritische Probleme" "ERROR"
}

Write-Log "`nValidierungs-Log gespeichert: $LogPath"
Write-Log "=== System-Validierung abgeschlossen ===" "INFO"
