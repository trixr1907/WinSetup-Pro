function Write-WinSetupLog {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Message,

    [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR', 'SUCCESS')]
    [string]$Level = 'INFO',

    [string]$LogPath,

    [string]$JsonLogPath
  )

  $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $line = "[$timestamp] [$Level] $Message"

  $color = switch ($Level) {
    'ERROR' { 'Red' }
    'WARN' { 'Yellow' }
    'SUCCESS' { 'Green' }
    'DEBUG' { 'DarkGray' }
    default { 'White' }
  }

  Write-Host $line -ForegroundColor $color

  if ($LogPath) {
    $dir = Split-Path -Parent $LogPath
    if ($dir -and -not (Test-Path $dir)) {
      New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Add-Content -Path $LogPath -Value $line -Encoding utf8
  }

  if ($JsonLogPath) {
    $dir = Split-Path -Parent $JsonLogPath
    if ($dir -and -not (Test-Path $dir)) {
      New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $obj = [ordered]@{
      timestamp = $timestamp
      level = $Level
      message = $Message
    }
    Add-Content -Path $JsonLogPath -Value ($obj | ConvertTo-Json -Compress) -Encoding utf8
  }
}

