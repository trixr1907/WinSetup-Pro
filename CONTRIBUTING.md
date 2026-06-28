# Mitwirken (Contributing)

## Grundregeln
- Aenderungen klein und gut reviewbar halten.
- Safe Defaults bevorzugen; alles mit Security-Impact muss Opt-in sein und dokumentiert werden.
- Keine deprecated/umstrittenen Tools als Default hinzufuegen ohne sehr gute Begruendung.

## Entwicklung
### Checks lokal ausfuehren
```powershell
pwsh -ExecutionPolicy Bypass -File scripts/Invoke-RepoChecks.ps1
```

### Code-Style
- Nur PowerShell 7+.
- Fuer Funktionen approved verbs nutzen.
- Das Modul (`src/WinSetup.Pro`) bevorzugen statt ad-hoc Script-Logik.

## Pull Requests
- User-visible Verhaltensaenderungen erklaeren.
- Docs aktualisieren, wenn du Profile/Catalog-Verhalten aenderst.
