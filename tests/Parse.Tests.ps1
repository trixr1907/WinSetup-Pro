#requires -Version 7.0

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$paths = @(
  (Join-Path $repoRoot 'src'),
  (Join-Path $repoRoot 'scripts'),
  (Join-Path $repoRoot 'tests')
)

$ps1Files = Get-ChildItem -Path $paths -Recurse -Filter '*.ps1' -File

Describe 'PowerShell-Parsing' {
  foreach ($file in $ps1Files) {
    It ("parst ohne Fehler: {0}" -f $file.FullName) {
      $tokens = $null
      $errors = $null
      [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
      $errors.Count | Should -Be 0
    }
  }
}
