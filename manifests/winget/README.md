# Winget Manifeste

Empfohlener Workflow:
1. Bereite eine saubere Maschine vor und installiere via Orchestrator im `Latest` Mode.
2. Exportiere gepinnte Versionen:
   - `winget export --include-versions --output manifests/winget/<profile>.json`
3. Committe das Manifest als Teil eines getaggten Releases.
