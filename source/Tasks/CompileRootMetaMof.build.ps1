param
(
    # Project path
    [Parameter()]
    [System.String]
    $ProjectPath = (property ProjectPath $BuildRoot),

    # Source path
    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath 'source'),

    [Parameter()]
    # Base directory of all output (default to 'output')
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [string]
    $DatumConfigDataDirectory = (property DatumConfigDataDirectory 'source'),

    [Parameter()]
    [string]
    $MetaMofOutputFolder = (property MetaMofOutputFolder 'MetaMOF'),

    # Build Configuration object
    [Parameter()]
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ })
)

task CompileRootMetaMof {
    . Set-SamplerTaskVariable -AsNewBuild

    $MetaMofOutputFolder = Get-SamplerAbsolutePath -Path $MetaMofOutputFolder -RelativeTo $OutputDirectory

    $originalPSModulePath = $env:PSModulePath
    try
    {
        $env:PSModulePath = ($env:PSModulePath -split [io.path]::PathSeparator).Where({
            $_ -notmatch ([regex]::Escape('powershell\7\Modules')) -and
            $_ -notmatch ([regex]::Escape('Program Files\WindowsPowerShell\Modules')) -and
            $_ -notmatch ([regex]::Escape('Documents\PowerShell\Modules'))
        }) -join [io.path]::PathSeparator

        if (-not (Test-Path -Path $MetaMofOutputFolder))
        {
            $null = New-Item -ItemType Directory -Path $MetaMofOutputFolder
        }

        if ($configurationData.AllNodes)
        {
            . (Join-Path -Path $SourcePath -ChildPath 'RootMetaMof.ps1')
            $metaMofs = RootMetaMOF -ConfigurationData $configurationData -OutputPath $MetaMofOutputFolder
            Write-Build Green "Successfully compiled $($metaMofs.Count) Meta MOF files."
        }
        else
        {
            Write-Build Green "No data to compile Meta MOF files"
        }
    }
    finally
    {
        $env:PSModulePath = $originalPSModulePath
    }
}
