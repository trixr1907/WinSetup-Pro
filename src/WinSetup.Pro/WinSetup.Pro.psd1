@{
  RootModule = 'WinSetup.Pro.psm1'
  ModuleVersion = '0.1.0'
  GUID = '3f9f62f2-7f30-4f9a-bc20-96a13ce2a4e8'
  Author = 'WinSetup-Pro'
  CompanyName = ''
  Copyright = '(c) 2026'
  Description = 'Windows workstation setup orchestrator with profiles, package policies and CI checks.'
  PowerShellVersion = '7.0'
  CompatiblePSEditions = @('Core')

  FunctionsToExport = @(
    'Invoke-WinSetup',
    'Get-WinSetupPlan',
    'Install-WinSetupPackages',
    'Invoke-WinSetupActions',
    'Start-WinSetupServices',
    'Write-WinSetupLog'
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @()

  PrivateData = @{
    PSData = @{
      Tags = @('windows', 'setup', 'automation', 'winget', 'chocolatey')
      LicenseUri = 'LICENSE'
    }
  }
}
