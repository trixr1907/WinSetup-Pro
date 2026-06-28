# Release / Pinned Manifeste

Der Default-InstallMode ist `Pinned`. Pinned-Installationen werden gesteuert durch:
1. Optionale `versionPinned` Felder in `packages/catalog.json`
2. Optionale Manifeste unter `manifests/`

## Winget export/import
Erzeuge ein winget Manifest fuer ein Profil (Beispiel):
```powershell
winget export --include-versions --output manifests/winget/dev.json
```

Der Import passiert automatisch (wenn die Datei existiert) via:
- `winget import -i manifests/winget/dev.json ...`

## Chocolatey packages.config
Pflege eine `packages.config` pro Profil:
- `manifests/choco/dev/packages.config`

Der Import passiert automatisch (wenn die Datei existiert) via:
- `choco install manifests/choco/dev/packages.config -y ...`
