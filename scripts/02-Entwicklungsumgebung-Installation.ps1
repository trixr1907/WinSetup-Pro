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
        $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    }
} catch {
    Write-Host "  ❌ Chocolatey Installation fehlgeschlagen: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✓ Chocolatey bereits installiert" -ForegroundColor Green
}

# winget aktualisieren
Write-Host "  winget wird aktualisiert..." -ForegroundColor Cyan
try {
    winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
    Write-Host "  ✓ winget aktualisiert" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ winget Update übersprungen" -ForegroundColor Yellow
}

# 2. Git Installation und Konfiguration
Write-Host "`n2. Git wird installiert und konfiguriert..." -ForegroundColor Yellow

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Git wird installiert..." -ForegroundColor Cyan
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
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
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ VS Code erfolgreich installiert" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ VS Code bereits installiert" -ForegroundColor Green
}

# VS Code Extensions installieren
Write-Host "  VS Code Extensions werden installiert..." -ForegroundColor Cyan
$vsCodeExtensions = @(
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss", 
    "esbenp.prettier-vscode",
    "ms-python.python",
    "ms-vscode.powershell",
    "GitLens.gitlens",
    "ms-vscode-remote.remote-wsl",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-dotnettools.csharp",
    "ms-vscode.vscode-docker",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "ms-vscode.vscode-eslint"
)

foreach ($extension in $vsCodeExtensions) {
    try {
        code --install-extension $extension --force
        Write-Host "    ✓ $extension installiert" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ $extension Installation fehlgeschlagen" -ForegroundColor Red
    }
}

# 4. Node.js Installation (LTS Version)
Write-Host "`n4. Node.js (LTS) wird installiert..." -ForegroundColor Yellow

if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "  Node.js wird installiert..." -ForegroundColor Cyan
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
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
    $globalPackages = @("yarn", "typescript", "nodemon", "@angular/cli", "create-react-app", "eslint", "prettier")
    
    foreach ($package in $globalPackages) {
        npm install -g $package --silent
        Write-Host "    ✓ $package installiert" -ForegroundColor Green
    }
}

# 5. Python Installation
Write-Host "`n5. Python wird installiert..." -ForegroundColor Yellow

if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Python wird installiert..." -ForegroundColor Cyan
    winget install --id Python.Python.3.12 -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $pythonVersion = python --version
        Write-Host "  ✓ Python $pythonVersion erfolgreich installiert" -ForegroundColor Green
    }
} else {
    $pythonVersion = python --version
    Write-Host "  ✓ Python $pythonVersion bereits installiert" -ForegroundColor Green
}

# pip und wichtige Python-Pakete installieren (mit uv wenn verfügbar)
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "  Python-Pakete werden installiert..." -ForegroundColor Cyan
    
    # uv installieren (moderne pip-Alternative)
    try {
        python -m pip install uv --quiet
        Write-Host "    ✓ uv (moderner Python Package Manager) installiert" -ForegroundColor Green
        
        # Mit uv wichtige Pakete installieren
        uv pip install --system virtualenv requests flask django fastapi
        Write-Host "    ✓ Python Development-Pakete mit uv installiert" -ForegroundColor Green
    } catch {
        # Fallback zu pip
        python -m pip install --upgrade pip virtualenv requests flask django fastapi --quiet
        Write-Host "    ✓ Python Development-Pakete mit pip installiert" -ForegroundColor Green
    }
}

# 6. .NET SDK Installation
Write-Host "`n6. .NET SDK wird installiert..." -ForegroundColor Yellow

if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "  .NET SDK wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.DotNet.SDK.8 -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        $dotnetVersion = dotnet --version
        Write-Host "  ✓ .NET SDK $dotnetVersion erfolgreich installiert" -ForegroundColor Green
    }
} else {
    $dotnetVersion = dotnet --version
    Write-Host "  ✓ .NET SDK $dotnetVersion bereits installiert" -ForegroundColor Green
}

# 7. Java Development Kit (OpenJDK)
Write-Host "`n7. Java JDK wird installiert..." -ForegroundColor Yellow

if (!(Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Host "  OpenJDK wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.OpenJDK.21 -e --source winget --accept-source-agreements --accept-package-agreements --silent
    
    # PATH aktualisieren
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
    
    if (Get-Command java -ErrorAction SilentlyContinue) {
        $javaVersion = java -version 2>&1 | Select-Object -First 1
        Write-Host "  ✓ Java JDK erfolgreich installiert: $javaVersion" -ForegroundColor Green
    }
} else {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Java JDK bereits installiert: $javaVersion" -ForegroundColor Green
}

# 8. Docker Desktop Installation
Write-Host "`n8. Docker Desktop wird installiert..." -ForegroundColor Yellow

$dockerInstalled = Get-ChildItem "C:\Program Files\Docker\Docker" -ErrorAction SilentlyContinue
if (!$dockerInstalled) {
    Write-Host "  Docker Desktop wird installiert..." -ForegroundColor Cyan
    Write-Host "  ⚠️ HINWEIS: Docker benötigt einen Neustart und WSL2" -ForegroundColor Yellow
    
    winget install --id Docker.DockerDesktop -e --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "  ✓ Docker Desktop Installation gestartet" -ForegroundColor Green
    Write-Host "  ⚠️ Docker Setup nach Neustart abschließen" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Docker Desktop bereits installiert" -ForegroundColor Green
}

# 9. Windows Subsystem for Linux (WSL2) aktivieren
Write-Host "`n9. Windows Subsystem for Linux (WSL2) wird aktiviert..." -ForegroundColor Yellow

$wslStatus = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslStatus.State -ne "Enabled") {
    Write-Host "  WSL wird aktiviert..." -ForegroundColor Cyan
    if ($isAdmin) {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Write-Host "  ✓ WSL2 Features aktiviert (Neustart erforderlich)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Administrator-Rechte für WSL-Aktivierung erforderlich"
    }
} else {
    Write-Host "  ✓ WSL bereits aktiviert
    Write-Host "  ✓ WSL bereits aktiviert" -ForegroundColor Green
}

# Ubuntu für WSL installieren
try {
    wsl --list --verbose 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Ubuntu für WSL wird installiert..." -ForegroundColor Cyan
        wsl --install -d Ubuntu --no-launch
        Write-Host "  ✓ Ubuntu für WSL installiert" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️ WSL Ubuntu-Installation übersprungen (nach Neustart verfügbar)" -ForegroundColor Yellow
}

# 10. Windows Terminal Installation
Write-Host "`n10. Windows Terminal wird installiert..." -ForegroundColor Yellow

$terminalInstalled = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
if (!$terminalInstalled) {
    Write-Host "  Windows Terminal wird installiert..." -ForegroundColor Cyan
    winget install --id Microsoft.WindowsTerminal -e --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-Host "  ✓ Windows Terminal installiert" -ForegroundColor Green
} else {
    Write-Host "  ✓ Windows Terminal bereits installiert" -ForegroundColor Green
}

# 11. Zusätzliche Entwicklertools
Write-Host "`n11. Zusätzliche Entwicklertools werden installiert..." -ForegroundColor Yellow

$additionalTools = @{
    "Postman" = "Postman.Postman"
    "Insomnia" = "Kong.Insomnia"
    "Database Browser (SQLite)" = "sqlitebrowser.sqlitebrowser"
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

# 12. VS Code Konfiguration erstellen
Write-Host "`n12. VS Code Konfiguration wird erstellt..." -ForegroundColor Yellow

$vscodeConfigDir = "$env:APPDATA\Code\User"
if (!(Test-Path $vscodeConfigDir)) {
    New-Item -Path $vscodeConfigDir -ItemType Directory -Force | Out-Null
}

$vscodeSettings = @{
    "editor.fontSize" = 14
    "editor.tabSize" = 2
    "editor.insertSpaces" = $true
    "editor.formatOnSave" = $true
    "editor.defaultFormatter" = "esbenp.prettier-vscode"
    "prettier.singleQuote" = $false
    "prettier.semi" = $true
    "prettier.tabWidth" = 2
    "typescript.preferences.includePackageJsonAutoImports" = "auto"
    "javascript.preferences.includePackageJsonAutoImports" = "auto"
    "git.enableSmartCommit" = $true
    "git.autofetch" = $true
    "terminal.integrated.defaultProfile.windows" = "PowerShell"
    "workbench.startupEditor" = "newUntitledFile"
    "files.autoSave" = "afterDelay"
    "files.autoSaveDelay" = 1000
}

$vscodeSettingsPath = "$vscodeConfigDir\settings.json"
$vscodeSettings | ConvertTo-Json -Depth 10 | Out-File -FilePath $vscodeSettingsPath -Encoding UTF8
Write-Host "  ✓ VS Code Konfiguration erstellt" -ForegroundColor Green

# 13. Entwicklungsordner erstellen
Write-Host "`n13. Entwicklungsordner werden erstellt..." -ForegroundColor Yellow

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

# 14. Git SSH-Keys Vorbereitung
Write-Host "`n14. SSH-Keys für Git werden vorbereitet..." -ForegroundColor Yellow

$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
    Write-Host "  ✓ SSH-Verzeichnis erstellt" -ForegroundColor Green
}

$sshKeyPath = "$sshDir\id_rsa"
if (!(Test-Path $sshKeyPath)) {
    Write-Host "  SSH-Key Erstellung:" -ForegroundColor Cyan
    Write-Host "  Führen Sie manuell aus: ssh-keygen -t rsa -b 4096 -C '$gitUserEmail'" -ForegroundColor Yellow
    Write-Host "  Dann: Get-Content ~\.ssh\id_rsa.pub | Set-Clipboard" -ForegroundColor Yellow
}

# 15. Zusammenfassung und nächste Schritte
Write-Host "`n=== Entwicklungsumgebung-Installation abgeschlossen ===" -ForegroundColor Green

$installationSummary = @"
Installierte Komponenten:
✓ Package Manager: Chocolatey, winget
✓ Git mit Basis-Konfiguration
✓ Visual Studio Code mit Extensions
✓ Node.js LTS mit npm/yarn und TypeScript
✓ Python mit uv/pip und Development-Pakete
✓ .NET SDK (neueste Version)
✓ Java OpenJDK
✓ Docker Desktop (Setup nach Neustart abschließen)
✓ WSL2 Ubuntu (bei Admin-Rechten)
✓ Windows Terminal
✓ Entwicklertools: Postman, FileZilla, WinSCP, etc.
✓ VS Code Konfiguration (Prettier, TypeScript)
✓ Entwicklungsordner-Struktur
✓ SSH-Verzeichnis vorbereitet

Manuelle Nacharbeiten erforderlich:
- SSH-Keys für Git generieren und zu GitHub/GitLab hinzufügen
- Docker Desktop nach Neustart einrichten
- WSL2 Ubuntu initial konfigurieren
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
