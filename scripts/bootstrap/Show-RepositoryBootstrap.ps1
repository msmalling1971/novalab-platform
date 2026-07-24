[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    }
    else {
        $RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }

    $configPath = Join-Path $RepositoryRoot 'config\repository-bootstrap.json'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Repository Bootstrap configuration was not found: $configPath"
    }

    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ([string]::IsNullOrWhiteSpace([string]$config.repositoryName)) {
        throw "The repositoryName setting is required in $configPath"
    }

    $requiredPaths = @(
        [string]$config.startHerePath
        [string]$config.checkpointDirectory
        [string]$config.developmentEnvironmentPath
        [string]$config.architecturePath
    )

    foreach ($relativePath in $requiredPaths) {
        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            throw "A required documentation path is missing from $configPath"
        }

        if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $relativePath))) {
            throw "A configured Repository Bootstrap path does not exist: $relativePath"
        }
    }

    $bullet = [char]0x2022
    $message = @"
$($config.repositoryName)

Today's Reminder

$bullet Read START HERE
$bullet Review today's checkpoint
$bullet Run git status
$bullet Confirm today's objective

Happy Engineering.
"@

    $isWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
    if ($isWindows -and [Environment]::UserInteractive) {
        try {
            Add-Type -AssemblyName PresentationFramework
            [void][System.Windows.MessageBox]::Show(
                $message,
                'Repository Bootstrap Framework',
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }
        catch {
            Write-Warning 'The graphical reminder was unavailable. Showing it in the terminal.'
            Write-Host $message
        }
    }
    else {
        Write-Host $message
    }
}
catch {
    Write-Warning "Repository Bootstrap Framework could not load: $($_.Exception.Message)"
    Write-Warning 'Startup will continue without the graphical reminder.'
}
