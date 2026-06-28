# Sicherheitsrichtlinie

## Unterstuetzte Versionen
Dieses Repository ist ein Setup-/Orchestrierungsprojekt. Unterstuetzt werden nur der aktuelle Stand von `main` sowie das neueste getaggte Release.

## Schwachstelle melden
Bitte keine oeffentlichen Issues fuer sicherheitssensitive Meldungen erstellen.

Sende stattdessen einen Report mit:
- Klarer Beschreibung des Problems und der Auswirkungen
- Repro-Schritten (falls anwendbar)
- Betroffenen Dateien/Kommandos

an die Maintainer ueber einen privaten Kanal (z.B. GitHub Security Advisories, falls im Repo aktiviert).

## Supply Chain (Lieferkette) / Installationssicherheit
Dieses Projekt folgt Best Practices:
- Keine Remote-`Invoke-Expression` Bootstraps
- Sicher per Default: Systemaenderungen (Opt-in)
- CI Policy Checks gegen unsichere Muster
