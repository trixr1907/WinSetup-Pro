function Expand-WinSetupString {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Value
  )

  # Expand %VAR% style environment variables used in JSON profiles.
  return ([regex]::Replace($Value, '%([^%]+)%', {
    param($m)
    $name = $m.Groups[1].Value
    $envValue = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($envValue)) { return $m.Value }
    return $envValue
  }))
}

