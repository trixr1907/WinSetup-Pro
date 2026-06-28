# Profile

Profile liegen unter `profiles/*.json` und definieren:
- `packages`: kanonische Keys, die auf `packages/catalog.json` verweisen
- `actions`: optionale System-Aktionen (immer sicher per Default; Opt-in wo noetig)
- `services`: DB/Web/HomeAssistant Modes und Compose-Files
- `requirements.adminRequired`: Info-Flag (einige Profile brauchen typischerweise Admin)

## Neues Profil erstellen
1. Kopiere ein bestehendes Profil (z.B. `profiles/dev.json`).
2. Passe `metadata.name` und `metadata.description` an.
3. Fuege Package-Keys hinzu, die in `packages/catalog.json` existieren.
4. Security-impacting Aktionen bleiben Opt-in (keine impliziten Firewall/Defender/Policy-Aenderungen).
