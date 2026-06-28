#requires -Version 7.0

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Describe 'PII-Hygiene' {
  It 'config/ Root enthaelt keine maschinen-/user-spezifischen Pfade' {
    $configRoot = Join-Path $repoRoot 'config'
    $files = Get-ChildItem -Path $configRoot -File

    $patterns = @(
      'C:\\\\Users\\\\',
      'DESKTOP-',
      '@hotmail\\.',
      '@gmail\\.'
    )

    foreach ($f in $files) {
      $raw = Get-Content -Path $f.FullName -Raw -ErrorAction Stop
      foreach ($pat in $patterns) {
        $raw | Should -Not -Match $pat
      }
    }
  }
}
