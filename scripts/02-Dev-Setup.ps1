# Windows Post-Install Setup - Schritt 2: Entwicklungsumgebung-Installation
Write-Host "=== Entwicklungsumgebung-Installation wird gestartet ===" -ForegroundColor Green

# Prüfen ob Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "⚠️ Für beste Ergebnisse als Administrator ausführen." -ForegroundColor Yellow
}

# Git Installation
Write-Host "`n1. Git wird installiert..." -ForegroundColor Yellow
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --silent
    Write-Host "✓ Git installiert" -ForegroundColor Green
} else {
    Write-Host "✓ Git bereits vorhanden" -ForegroundColor Green
}

# Git Konfiguration
$gitName = Read-Host "Git Benutzername"
$gitEmail = Read-Host "Git E-Mail"
git config --global user.name "$gitName"
git config --global user.email "$gitEmail"
git config --global init.defaultBranch main

# Visual Studio Code
Write-Host "`n2. Visual Studio Code wird installiert..." -ForegroundColor Yellow
if (!(Get-Command code -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.VisualStudioCode -e --silent
    Write-Host "✓ VS Code installiert" -ForegroundColor Green
} else {
    Write-Host "✓ VS Code bereits vorhanden" -ForegroundColor Green
}

# Node.js
Write-Host "`n3. Node.js wird installiert..." -ForegroundColor Yellow
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    winget install --id OpenJS.NodeJS.LTS -e --silent
    Write-Host "✓ Node.js installiert" -ForegroundColor Green
} else {
    Write-Host "✓ Node.js bereits vorhanden" -ForegroundColor Green
}

# Python
Write-Host "`n4. Python wird installiert..." -ForegroundColor Yellow
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    winget install --id Python.Python.3.12 -e --silent
    Write-Host "✓ Python installiert" -ForegroundColor Green
} else {
    Write-Host "✓ Python bereits vorhanden" -ForegroundColor Green
}

# .NET SDK
Write-Host "`n5. .NET SDK wird installiert..." -ForegroundColor Yellow
if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.DotNet.SDK.8 -e --silent
    Write-Host "✓ .NET SDK installiert" -ForegroundColor Green
} else {
    Write-Host "✓ .NET SDK bereits vorhanden" -ForegroundColor Green
}

# Docker Desktop
Write-Host "`n6. Docker Desktop wird installiert..." -ForegroundColor Yellow
if (!(Test-Path "C:\Program Files\Docker\Docker")) {
    winget install --id Docker.DockerDesktop -e --silent
    Write-Host "✓ Docker Desktop installiert" -ForegroundColor Green
} else {
    Write-Host "✓ Docker Desktop bereits vorhanden" -ForegroundColor Green
}

# Windows Terminal
Write-Host "`n7. Windows Terminal wird installiert..." -ForegroundColor Yellow
$terminal = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
if (!$terminal) {
    winget install --id Microsoft.WindowsTerminal -e --silent
    Write-Host "✓ Windows Terminal installiert" -ForegroundColor Green
} else {
    Write-Host "✓ Windows Terminal bereits vorhanden" -ForegroundColor Green
}

# Entwicklungsordner erstellen
Write-Host "`n8. Entwicklungsordner werden erstellt..." -ForegroundColor Yellow
$folders = @(
    "$env:USERPROFILE\Documents\GitHub",
    "$env:USERPROFILE\Documents\Projects",
    "$env:USERPROFILE\Documents\Projects\Web"
)

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Host "✓ Erstellt: $folder" -ForegroundColor Green
    }
}

# SSH-Ordner
Write-Host "`n9. SSH-Konfiguration..." -ForegroundColor Yellow
$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
    Write-Host "✓ SSH-Ordner erstellt" -ForegroundColor Green
}

# Log erstellen
Write-Host "`n10. Installation dokumentieren..." -ForegroundColor Yellow
$logContent = @"
Entwicklungsumgebung Installation - $(Get-Date)
Computer: $env:COMPUTERNAME

Installierte Software:
- Git
- Visual Studio Code 
- Node.js LTS
- Python 3.12
- .NET SDK 8
- Docker Desktop
- Windows Terminal

Nächste Schritte:
- SSH Keys generieren: ssh-keygen -t rsa -b 4096 -C "$gitEmail"
- VS Code Extensions installieren
- Docker nach Neustart konfigurieren
"@

$configDir = "$PSScriptRoot\..\config"
if (!(Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

$logPath = "$configDir\Dev-Setup-Log.txt"
$logContent | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "✓ Log erstellt: $logPath" -ForegroundColor Green

Write-Host "`n=== Installation abgeschlossen ===" -ForegroundColor Green
Write-Host "⚠️ Neustart für Docker empfohlen" -ForegroundColor Yellow
Write-Host "`nDruecken Sie Enter zum Fortfahren..."
Read-Host
