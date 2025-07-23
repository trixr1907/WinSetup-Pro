Write-Host "=== System-Validation gestartet ===" -ForegroundColor Green
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "Benutzer: $env:USERNAME" -ForegroundColor Cyan
Write-Host "Datum: $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

$successful = 0
$failed = 0

function Test-Tool {
    param([string]$Command, [string]$Name)
    try {
        $result = Get-Command $Command -ErrorAction SilentlyContinue
        if ($result) {
            Write-Host "✅ $Name - Verfügbar" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Name - Nicht gefunden" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $Name - Fehler" -ForegroundColor Red
        return $false
    }
}

Write-Host "=== Entwicklungstools ===" -ForegroundColor Yellow
$tools = @("git", "node", "npm", "code", "docker")
foreach ($tool in $tools) {
    if (Test-Tool $tool $tool) {
        $successful++
    } else {
        $failed++
    }
}

Write-Host "`n=== Package Manager ===" -ForegroundColor Yellow
if (Test-Tool "winget" "WinGet") { $successful++ } else { $failed++ }
if (Test-Tool "choco" "Chocolatey") { $successful++ } else { $failed++ }

Write-Host "`n=== System-Info ===" -ForegroundColor Yellow
$os = Get-CimInstance Win32_OperatingSystem
$memory = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$freeMemory = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
Write-Host "Windows Version: $($os.Caption)" -ForegroundColor Cyan
Write-Host "RAM Total: $memory GB" -ForegroundColor Cyan
Write-Host "RAM Frei: $freeMemory GB" -ForegroundColor Cyan

Write-Host "`n=== Verzeichnisse ===" -ForegroundColor Yellow
$directories = @(
    "$env:USERPROFILE\Development",
    "$env:USERPROFILE\Database-Backups",
    ".\config",
    ".\scripts"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "✅ $(Split-Path $dir -Leaf) - Existiert" -ForegroundColor Green
        $successful++
    } else {
        Write-Host "❌ $(Split-Path $dir -Leaf) - Fehlt" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n=== ZUSAMMENFASSUNG ===" -ForegroundColor Magenta
Write-Host "✅ Erfolgreich: $successful" -ForegroundColor Green
Write-Host "❌ Fehlgeschlagen: $failed" -ForegroundColor Red

$total = $successful + $failed
if ($total -gt 0) {
    $rate = [math]::Round(($successful / $total) * 100, 1)
    Write-Host "📊 Erfolgsrate: $rate%" -ForegroundColor Cyan
    
    if ($failed -eq 0) {
        Write-Host "🎉 System vollständig funktionsfähig!" -ForegroundColor Green
    } elseif ($failed -le 2) {
        Write-Host "⚠️ System größtenteils funktionsfähig" -ForegroundColor Yellow
    } else {
        Write-Host "❌ System benötigt Nacharbeit" -ForegroundColor Red
    }
}

Write-Host "`n=== Validation abgeschlossen ===" -ForegroundColor Green
