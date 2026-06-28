#requires -Version 7.0

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Read-JsonFile([string]$Path) {
  if (-not (Test-Path $Path)) { throw "Fehlende JSON: $Path" }
  return ((Get-Content -Path $Path -Raw -Encoding utf8) | ConvertFrom-Json -Depth 100)
}

Describe 'JSON-Schema' {
  It 'packages/catalog.json ist valide und konsistent' {
    $catalogPath = Join-Path $repoRoot 'packages/catalog.json'
    $catalog = Read-JsonFile $catalogPath

    $catalog | Should -Not -BeNullOrEmpty

    $keys = @{}
    foreach ($p in $catalog) {
      $p.key | Should -Not -BeNullOrEmpty
      $p.winget.id | Should -Not -BeNullOrEmpty
      $p.winget.source | Should -Not -BeNullOrEmpty
      $p.choco.id | Should -Not -BeNullOrEmpty
      ($p.requiresAdmin -is [bool]) | Should -BeTrue
      $p.notes | Should -Not -BeNullOrEmpty
      ($p.deprecated -is [bool]) | Should -BeTrue
      $keys[$p.key] = $true
    }

    $keys.Count | Should -BeGreaterThan 0
  }

  It 'Profile sind valide und referenzieren existierende Package-Keys' {
    $profilesDir = Join-Path $repoRoot 'profiles'
    $profileFiles = Get-ChildItem -Path $profilesDir -Filter '*.json' -File
    $catalog = Read-JsonFile (Join-Path $repoRoot 'packages/catalog.json')
    $catalogKeys = @{}
    foreach ($p in $catalog) { $catalogKeys[$p.key] = $true }

    foreach ($f in $profileFiles) {
      $profile = Read-JsonFile $f.FullName
      $profile.metadata.name | Should -Not -BeNullOrEmpty
      ($profile.requirements.adminRequired -is [bool]) | Should -BeTrue

      foreach ($key in @($profile.packages)) {
        $catalogKeys.ContainsKey([string]$key) | Should -BeTrue
      }

      foreach ($svcName in @('database', 'web', 'homeAssistant')) {
        $profile.services.$svcName.mode | Should -Not -BeNullOrEmpty
        $profile.services.$svcName.composeFile | Should -Not -BeNullOrEmpty
      }
    }
  }
}
