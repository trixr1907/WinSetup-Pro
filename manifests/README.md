# Manifeste (Gepinnte Installationen)

Dieser Ordner unterstuetzt **release-pinned** Installationen.

Konzept:
- Default-Mode ist `Pinned`.
- Ein Release sollte Manifeste unter folgenden Pfaden hinzufuegen/aktualisieren:
  - `manifests/winget/*.json` (erstellt via `winget export --include-versions`)
  - `manifests/choco/*/packages.config` (erstellt via `choco list --local-only` oder kuratiert manuell)

Zur Laufzeit:
- `Pinned` nutzt gepinnte Versionen, falls verfuegbar (Catalog `versionPinned` und/oder Manifeste).
- `Latest` ignoriert Pins.
