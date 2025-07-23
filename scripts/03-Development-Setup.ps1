# Windows Post-Install Setup - Development Environment
Write-Host "=== Development Environment Setup ===" -ForegroundColor Green

# Check admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Warning: Run as Administrator for best results" -ForegroundColor Yellow
}

# Install Git
Write-Host "`n1. Installing Git..." -ForegroundColor Yellow
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --silent
    Write-Host "Git installed successfully" -ForegroundColor Green
} else {
    Write-Host "Git already installed" -ForegroundColor Green
}

# Configure Git
$gitName = Read-Host "Enter Git username"
$gitEmail = Read-Host "Enter Git email"
git config --global user.name "$gitName"
git config --global user.email "$gitEmail"
git config --global init.defaultBranch main
Write-Host "Git configured" -ForegroundColor Green

# Install Visual Studio Code
Write-Host "`n2. Installing Visual Studio Code..." -ForegroundColor Yellow
if (!(Get-Command code -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.VisualStudioCode -e --silent
    Write-Host "VS Code installed successfully" -ForegroundColor Green
} else {
    Write-Host "VS Code already installed" -ForegroundColor Green
}

# Install Node.js
Write-Host "`n3. Installing Node.js..." -ForegroundColor Yellow
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    winget install --id OpenJS.NodeJS.LTS -e --silent
    Write-Host "Node.js installed successfully" -ForegroundColor Green
} else {
    Write-Host "Node.js already installed" -ForegroundColor Green
}

# Install Python
Write-Host "`n4. Installing Python..." -ForegroundColor Yellow
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    winget install --id Python.Python.3.12 -e --silent
    Write-Host "Python installed successfully" -ForegroundColor Green
} else {
    Write-Host "Python already installed" -ForegroundColor Green
}

# Install .NET SDK
Write-Host "`n5. Installing .NET SDK..." -ForegroundColor Yellow
if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.DotNet.SDK.8 -e --silent
    Write-Host ".NET SDK installed successfully" -ForegroundColor Green
} else {
    Write-Host ".NET SDK already installed" -ForegroundColor Green
}

# Install Docker Desktop
Write-Host "`n6. Installing Docker Desktop..." -ForegroundColor Yellow
$dockerPath = "C:\Program Files\Docker\Docker"
if (!(Test-Path $dockerPath)) {
    winget install --id Docker.DockerDesktop -e --silent
    Write-Host "Docker Desktop installed successfully" -ForegroundColor Green
    Write-Host "Note: Restart required for Docker" -ForegroundColor Yellow
} else {
    Write-Host "Docker Desktop already installed" -ForegroundColor Green
}

# Create development folders
Write-Host "`n7. Creating development folders..." -ForegroundColor Yellow
$folders = @(
    "$env:USERPROFILE\Documents\GitHub",
    "$env:USERPROFILE\Documents\Projects",
    "$env:USERPROFILE\Documents\Projects\Web"
)

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Host "Created: $folder" -ForegroundColor Green
    }
}

# Create SSH folder
Write-Host "`n8. Setting up SSH..." -ForegroundColor Yellow
$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
    Write-Host "SSH folder created" -ForegroundColor Green
}

# Create log
Write-Host "`n9. Creating installation log..." -ForegroundColor Yellow
$logText = @"
Development Environment Setup - $(Get-Date)
Computer: $env:COMPUTERNAME

Installed Software:
- Git (configured for $gitEmail)
- Visual Studio Code
- Node.js LTS
- Python 3.12
- .NET SDK 8
- Docker Desktop

Next Steps:
- Generate SSH keys: ssh-keygen -t rsa -b 4096 -C "$gitEmail"
- Install VS Code extensions
- Restart computer for Docker
"@

$configDir = "$PSScriptRoot\..\config"
if (!(Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

$logPath = "$configDir\Development-Setup-Log.txt"
$logText | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "Log saved to: $logPath" -ForegroundColor Green

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Restart recommended for Docker functionality" -ForegroundColor Yellow
Write-Host "Press Enter to continue..." -ForegroundColor Cyan
Read-Host
