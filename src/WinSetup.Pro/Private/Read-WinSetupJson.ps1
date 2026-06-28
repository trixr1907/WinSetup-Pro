function Read-WinSetupJson {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Path
  )

  if (-not (Test-Path $Path)) {
    throw ("JSON-Datei nicht gefunden: {0}" -f $Path)
  }

  try {
    $raw = Get-Content -Path $Path -Raw -Encoding utf8
    return ($raw | ConvertFrom-Json -Depth 100)
  } catch {
    throw ("JSON konnte nicht geparst werden: {0}. {1}" -f $Path, $_.Exception.Message)
  }
}
