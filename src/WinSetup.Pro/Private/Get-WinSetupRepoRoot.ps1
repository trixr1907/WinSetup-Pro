function Get-WinSetupRepoRoot {
  [CmdletBinding()]
  param(
    [string]$RepoRoot
  )

  $candidates = @()

  if ($RepoRoot) {
    $candidates += $RepoRoot
  }

  # When running from source repo: <repo>/src/WinSetup.Pro/(Public|Private)
  $moduleRoot = Split-Path -Parent $PSScriptRoot
  $candidates += (Join-Path $moduleRoot '..\..')

  # Fallback: walk up from current directory
  $cwd = (Get-Location).Path
  $candidates += $cwd

  foreach ($cand in $candidates) {
    try {
      $root = (Resolve-Path -Path $cand -ErrorAction Stop).Path
    } catch {
      continue
    }

    $catalogPath = Join-Path $root 'packages\catalog.json'
    if (Test-Path $catalogPath) {
      return $root
    }
  }

  # Walk upwards from CWD a few levels to discover repo root.
  $dir = (Get-Location).Path
  for ($i = 0; $i -lt 8; $i++) {
    $catalogPath = Join-Path $dir 'packages\catalog.json'
    if (Test-Path $catalogPath) { return $dir }
    $parent = Split-Path -Parent $dir
    if (-not $parent -or ($parent -eq $dir)) { break }
    $dir = $parent
  }

  throw 'Repo-Root konnte nicht gefunden werden (erwartet: packages/catalog.json).'
}
