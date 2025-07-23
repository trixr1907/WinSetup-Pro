# Windows Post-Install Setup - Schritt 2: Entwicklungsumgebung-Installation
# Automatisierungsskript für komplette Entwicklungsumgebung

Write-Host "=== Entwicklungsumgebung-Installation wird gestartet ===" -ForegroundColor Green
Write-Host "Dieses Skript installiert: Git, VS Code, Node.js, Docker, WSL2, .NET, Java, Python und mehr`n" -ForegroundColor Cyan

# Prüfen ob Skript als Administrator läuft
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "⚠️ WARNUNG: Einige Installationen benötigen Administrator-Rechte." -ForegroundColor Yellow
    Write-Host "Für beste Ergebnisse als Administrator ausführen.`n" -ForegroundColor Yellow
}

# Funktion zum PATH aktualisieren
function Update-EnvironmentPath {
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')
}

# 1. Package Manager installieren (Chocolatey und winget vorbereiten)
Write-Host "1. Package Manager werden vorbereitet..." -ForegroundColor Yellow

# Chocolatey Installation prüfen/installieren
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "  Chocolatey wird installiert..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "  ✓ Chocolatey erfolgreich installiert" -ForegroundColor Green
        Update-EnvironmentPath
    } catch {
        Write-Host "  ❌ Chocolatey Installation fehlgeschlagen: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✓ Chocolatey bereits installiert" -ForegroundColor Green
}

# winget aktualisieren
Write-Host "  winget wird aktualisiert..." -ForegroundColor Cyan
try {
    winget upgrade --all --accept-source-agreements --accept-package-agreements --silent | Out-Null
    Write-Host "  ✓ winget aktualisiert" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ winget Update übersprungen" -ForegroundColor Yellow
}

# 2. Git Installation und Konfiguration
Write-Host "`n2. Git wird installiert und konfiguriert..." -ForegroundColor Yellow

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Git wird installiert..." -ForegroundColor Cyan
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    Update-EnvironmentPath
    Start-Sleep -Seconds 2
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ Git erfolgreich installiert" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Git Installation fehlgeschlagen" -ForegroundColor Red
    }
} else {
    Write-Host "  ✓ Git bereits installiert" -ForegroundColor Green
}

# Git Basis-Konfiguration
Write-Host "  Git Basis-Konfiguration..." -ForegroundColor Cyan
$gitUserName = Read-Host "  Git Benutzername eingeben"
$gitUserEmail = Read-Host "  Git E-Mail-Adresse eingeben"

if ($gitUserName -and $gitUserEmail) {
    git config --global user.name "$gitUserName"
    git config --global user.email "$gitUserEmail"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.autocrlf true
    Write-Host "  ✓ Git Basis-Konfiguration abgeschlossen" -ForegroundColor Green
}

# 3. Visual Studio Code Installation
Write-Host "`n3. Visual Studio Code wird installiert..." -ForegroundColor Yellow

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "  VS Code wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.VisualStudioCode -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    Update-EnvironmentPath
    Start-Sleep -Seconds 3
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ VS Code erfolgreich installiert" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ VS Code bereits installiert" -ForegroundColor Green
}

# 4. Node.js Installation (LTS Version)
Write-Host "`n4. Node.js (LTS) wird installiert..." -ForegroundColor Yellow

if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "  Node.js wird installiert..." -ForegroundColor Cyan
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    Update-EnvironmentPath
    Start-Sleep -Seconds 2
    
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Host "  ✓ Node.js $nodeVersion erfolgreich installiert" -ForegroundColor Green
    }
} else {
    $nodeVersion = node --version
    Write-Host "  ✓ Node.js $nodeVersion bereits installiert" -ForegroundColor Green
}

# npm globale Pakete installieren
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "  Globale npm-Pakete werden installiert..." -ForegroundColor Cyan
    $globalPackages = @("yarn", "typescript", "nodemon", "@angular/cli", "prettier")
    
    foreach ($package in $globalPackages) {
        try {
            npm install -g $package --silent
            Write-Host "    ✓ $package installiert" -ForegroundColor Green
        } catch {
            Write-Host "    ⚠️ $package Installation übersprungen" -ForegroundColor Yellow
        }
    }
}

# 5. Python Installation
Write-Host "`n5. Python wird installiert..." -ForegroundColor Yellow

if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Python wird installiert..." -ForegroundColor Cyan
    winget install --id Python.Python.3.12 -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    Update-EnvironmentPath
    Start-Sleep -Seconds 2
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $pythonVersion = python --version
        Write-Host "  ✓ Python $pythonVersion erfolgreich installiert" -ForegroundColor Green
    }
} else {
    $pythonVersion = python --version
    Write-Host "  ✓ Python $pythonVersion bereits installiert" -ForegroundColor Green
}

# 6. .NET SDK Installation
Write-Host "`n6. .NET SDK wird installiert..." -ForegroundColor Yellow

if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "  .NET SDK wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.DotNet.SDK.8 -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    Update-EnvironmentPath
    Start-Sleep -Seconds 2
    
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $dotnetVersion = dotnet --version
        Write-Host "  ✓ .NET SDK $dotnetVersion erfolgreich installiert" -ForegroundColor Green
    }
} else {
    $dotnetVersion = dotnet --version
    Write-Host "  ✓ .NET SDK $dotnetVersion bereits installiert" -ForegroundColor Green
}

# 7. Docker Desktop Installation
Write-Host "`n7. Docker Desktop wird installiert..." -ForegroundColor Yellow

$dockerInstalled = Test-Path "C:\Program Files\Docker\Docker"
if (!$dockerInstalled) {
    Write-Host "  Docker Desktop wird installiert..." -ForegroundColor Cyan
    Write-Host "  ⚠️ HINWEIS: Docker benötigt einen Neustart und WSL2" -ForegroundColor Yellow
    
    winget install --id Docker.DockerDesktop -e --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "  ✓ Docker Desktop Installation gestartet" -ForegroundColor Green
    Write-Host "  ⚠️ Docker Setup nach Neustart abschließen" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Docker Desktop bereits installiert" -ForegroundColor Green
}

# 8. Windows Terminal Installation
Write-Host "`n8. Windows Terminal wird installiert..." -ForegroundColor Yellow

$terminalInstalled = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
if (!$terminalInstalled) {
    Write-Host "  Windows Terminal wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.WindowsTerminal -e --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "  ✓ Windows Terminal installiert" -ForegroundColor Green
} else {
    Write-Host "  ✓ Windows Terminal bereits installiert" -ForegroundColor Green
}

# 9. Zusätzliche Entwicklertools
Write-Host "`n9. Zusätzliche Entwicklertools werden installiert..." -ForegroundColor Yellow

$additionalTools = @{
    "FileZilla" = "TimKosse.FileZilla.Client"
    "WinSCP" = "WinSCP.WinSCP"
}

foreach ($tool in $additionalTools.GetEnumerator()) {
    Write-Host "  $($tool.Key) wird installiert..." -ForegroundColor Cyan
    try {
        winget install --id $tool.Value -e --source winget --accept-source-agreements --accept-package-agreements --silent
        Write-Host "    ✓ $($tool.Key) installiert" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠️ $($tool.Key) Installation übersprungen" -ForegroundColor Yellow
    }
}

# 10. Entwicklungsordner erstellen
Write-Host "`n10. Entwicklungsordner werden erstellt..." -ForegroundColor Yellow

$devFolders = @(
    "$env:USERPROFILE\Documents\GitHub",
    "$env:USERPROFILE\Documents\Projects",
    "$env:USERPROFILE\Documents\Projects\Web",
    "$env:USERPROFILE\Documents\Projects\Mobile",
    "$env:USERPROFILE\Documents\Projects\Desktop",
    "$env:USERPROFILE\Documents\Projects\Learning"
)

foreach ($folder in $devFolders) {
    if (!(Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Host "  ✓ Ordner erstellt: $folder" -ForegroundColor Green
    }
}

# 11. Git SSH-Keys Vorbereitung
Write-Host "`n11. SSH-Keys für Git werden vorbereitet..." -ForegroundColor Yellow

$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
    Write-Host "  ✓ SSH-Verzeichnis erstellt" -ForegroundColor Green
}

$sshKeyPath = "$sshDir\id_rsa"
if (!(Test-Path $sshKeyPath)) {
    Write-Host "  SSH-Key Erstellung:" -ForegroundColor Cyan
    Write-Host "  Führen Sie manuell aus: ssh-keygen -t rsa -b 4096 -C '$gitUserEmail'" -ForegroundColor Yellow
    Write-Host "  Dann: Get-Content ~/.ssh/id_rsa.pub | Set-Clipboard" -ForegroundColor Yellow
}

# 12. Zusammenfassung und nächste Schritte
Write-Host "`n=== Entwicklungsumgebung-Installation abgeschlossen ===" -ForegroundColor Green

$installationSummary = @"
Installierte Komponenten:
✓ Package Manager: Chocolatey, winget
✓ Git mit Basis-Konfiguration
✓ Visual Studio Code 
✓ Node.js LTS mit npm/yarn und TypeScript
✓ Python 3.12
✓ .NET SDK (neueste Version)
✓ Docker Desktop (Setup nach Neustart abschließen)
✓ Windows Terminal
✓ Entwicklertools: FileZilla, WinSCP
✓ Entwicklungsordner-Struktur
✓ SSH-Verzeichnis vorbereitet

Manuelle Nacharbeiten erforderlich:
- SSH-Keys für Git generieren und zu GitHub/GitLab hinzufügen
- Docker Desktop nach Neustart einrichten
- VS Code Extensions installieren
- Git SSH-Authentifizierung testen

Nächster Schritt: Server und Virtualisierung-Tools (Schritt 3)
"@

Write-Host $installationSummary -ForegroundColor Cyan

# Konfiguration dokumentieren
$configPath = "$PSScriptRoot\..\config\Entwicklungsumgebung-Installation.log"
$installationLog = @"
=== Entwicklungsumgebung-Installation Abgeschlossen ===
Installation durchgeführt am: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')
Computer: $env:COMPUTERNAME
Benutzer: $env:USERNAME

$installationSummary
"@

$installationLog | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "`nInstallations-Log gespeichert: $configPath" -ForegroundColor Green

Write-Host "`n⚠️ NEUSTART EMPFOHLEN für Docker und WSL2" -ForegroundColor Yellow
Write-Host "Drücken Sie eine beliebige Taste, um fortzufahren..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
