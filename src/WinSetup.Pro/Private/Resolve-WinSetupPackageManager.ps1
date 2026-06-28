function Resolve-WinSetupPackageManager {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateSet('Auto', 'Winget', 'Choco')]
    [string]$PackageManager
  )

  $hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
  $hasChoco = [bool](Get-Command choco -ErrorAction SilentlyContinue)

  switch ($PackageManager) {
    'Winget' {
      if (-not $hasWinget) { throw 'PackageManager=Winget wurde angefordert, aber winget ist nicht verfuegbar.' }
      return 'Winget'
    }
    'Choco' {
      if (-not $hasChoco) { throw 'PackageManager=Choco wurde angefordert, aber choco ist nicht verfuegbar.' }
      return 'Choco'
    }
    default {
      if ($hasWinget) { return 'Winget' }
      if ($hasChoco) { return 'Choco' }
      throw 'Weder winget noch choco ist verfuegbar.'
    }
  }
}
