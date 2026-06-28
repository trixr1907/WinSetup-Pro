function Get-WinSetupCatalogIndex {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [object[]]$Catalog
  )

  $index = @{}
  foreach ($entry in $Catalog) {
    if (-not $entry.key) { continue }
    $index[$entry.key] = $entry
  }
  return $index
}

