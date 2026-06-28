# Nutzung

## Orchestrator
Primaerer Einstiegspunkt:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 -Profiles dev
```

Haeufige Optionen:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 `
  -Profiles dev,security `
  -PackageManager Auto `
  -InstallMode Pinned `
  -NonInteractive `
  -AllowPartial
```

## Opt-in Security-Aktionen
Diese sind **deaktiviert per Default**:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 `
  -Profiles dev `
  -EnableFirewallDevPorts `
  -EnableDefenderExclusions
```

## Container-Services
DB + Web Container:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 `
  -Profiles full `
  -DatabaseMode Container `
  -WebMode Container
```

Home Assistant:
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-WinSetup.ps1 `
  -Profiles iot `
  -HomeAssistantMode Container
```
