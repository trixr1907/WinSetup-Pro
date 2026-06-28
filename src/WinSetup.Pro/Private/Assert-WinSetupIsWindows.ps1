function Assert-WinSetupIsWindows {
  [CmdletBinding()]
  param()

  if (-not $IsWindows) {
    throw 'WinSetup.Pro unterstuetzt aktuell nur Windows.'
  }
}
