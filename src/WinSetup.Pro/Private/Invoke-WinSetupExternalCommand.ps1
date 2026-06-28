function Invoke-WinSetupExternalCommand {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$FilePath,

    [Parameter(Mandatory)]
    [string[]]$ArgumentList,

    [string]$LogPath
  )

  $prettyArgs = ($ArgumentList | ForEach-Object {
    if ($_ -match '\\s') { '"{0}"' -f $_ } else { $_ }
  }) -join ' '

  Write-WinSetupLog -Message ("AUSFUEHREN: {0} {1}" -f $FilePath, $prettyArgs) -Level DEBUG -LogPath $LogPath

  & $FilePath @ArgumentList
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    throw ("Befehl fehlgeschlagen (ExitCode {0}): {1} {2}" -f $exitCode, $FilePath, $prettyArgs)
  }
}
