#requires -Version 7.0

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$scanPaths = @(
  (Join-Path $repoRoot 'src'),
  (Join-Path $repoRoot 'scripts')
)

Describe 'Repo-Policy' {
  It 'enthaelt keine Remote-Invoke-Expression Bootstraps' {
    $files = Get-ChildItem -Path $scanPaths -Recurse -Filter '*.ps1' -File
    $pattern = '(?im)(Invoke-Expression\\b|\\biex\\b).*(DownloadString\\(|WebClient|Invoke-WebRequest|iwr\\b)'

    $hits = @()
    foreach ($f in $files) {
      $raw = Get-Content -Path $f.FullName -Raw -ErrorAction Stop
      if ($raw -match $pattern) {
        $hits += $f.FullName
      }
    }

    $hits | Should -BeNullOrEmpty
  }

  It 'trackt keine Runtime-Logs unter config/' {
    $configRoot = Join-Path $repoRoot 'config'
    $tracked = Get-ChildItem -Path $configRoot -File
    $bad = $tracked | Where-Object { $_.Name -like '*.log' -or $_.Name -like '*-Log.txt' -or $_.Name -like '*Validation*.log' }
    $bad.Count | Should -Be 0
  }
}
