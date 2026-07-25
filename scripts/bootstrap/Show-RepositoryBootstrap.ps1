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
    $requiredTextSettings = @(
        'repositoryName'
        'windowTitle'
        'reminderHeading'
        'closingText'
        'continueButtonText'
    )

    foreach ($settingName in $requiredTextSettings) {
        if ([string]::IsNullOrWhiteSpace([string]$config.$settingName)) {
            throw "The $settingName setting is required in $configPath"
        }
    }

    if ($null -eq $config.reminderItems -or @($config.reminderItems).Count -eq 0) {
        throw "The reminderItems setting must contain at least one item in $configPath"
    }

    foreach ($reminderItem in @($config.reminderItems)) {
        if ([string]::IsNullOrWhiteSpace([string]$reminderItem)) {
            throw "The reminderItems setting cannot contain blank items in $configPath"
        }
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
    $reminderLines = @($config.reminderItems | ForEach-Object { "$bullet $_" })
    $messageLines = @(
        [string]$config.repositoryName
        ''
        [string]$config.reminderHeading
        ''
    ) + $reminderLines + @(
        ''
        [string]$config.closingText
    )
    $message = $messageLines -join [Environment]::NewLine

    $isWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
    if ($isWindows -and [Environment]::UserInteractive) {
        try {
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            [System.Windows.Forms.Application]::EnableVisualStyles()

            $form = New-Object System.Windows.Forms.Form
            $form.Text = [string]$config.windowTitle
            $form.ClientSize = New-Object System.Drawing.Size(760, 550)
            $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
            $form.MaximizeBox = $false
            $form.MinimizeBox = $false
            $form.ShowIcon = $false
            $form.ShowInTaskbar = $true
            $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            $form.KeyPreview = $true
            $form.Padding = New-Object System.Windows.Forms.Padding(44, 40, 44, 36)

            $layout = New-Object System.Windows.Forms.TableLayoutPanel
            $layout.ColumnCount = 1
            $layout.RowCount = 5
            $layout.Dock = [System.Windows.Forms.DockStyle]::Fill
            foreach ($rowType in @('AutoSize', 'AutoSize', 'Percent', 'AutoSize', 'AutoSize')) {
                $rowStyle = New-Object System.Windows.Forms.RowStyle
                $rowStyle.SizeType = [System.Enum]::Parse([System.Windows.Forms.SizeType], $rowType)
                if ($rowType -eq 'Percent') { $rowStyle.Height = 100 }
                [void]$layout.RowStyles.Add($rowStyle)
            }

            $repositoryLabel = New-Object System.Windows.Forms.Label
            $repositoryLabel.AutoSize = $true
            $repositoryLabel.Font = New-Object System.Drawing.Font($repositoryLabel.Font.FontFamily, 20, [System.Drawing.FontStyle]::Bold)
            $repositoryLabel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 28)
            $repositoryLabel.Text = [string]$config.repositoryName

            $headingLabel = New-Object System.Windows.Forms.Label
            $headingLabel.AutoSize = $true
            $headingLabel.Font = New-Object System.Drawing.Font($headingLabel.Font.FontFamily, 12, [System.Drawing.FontStyle]::Bold)
            $headingLabel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 16)
            $headingLabel.Text = [string]$config.reminderHeading

            $reminderLabel = New-Object System.Windows.Forms.Label
            $reminderLabel.AutoSize = $true
            $reminderLabel.Font = New-Object System.Drawing.Font($reminderLabel.Font.FontFamily, 11)
            $reminderLabel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 28)
            $reminderLabel.Text = $reminderLines -join ([Environment]::NewLine + [Environment]::NewLine)

            $closingLabel = New-Object System.Windows.Forms.Label
            $closingLabel.AutoSize = $true
            $closingLabel.Font = New-Object System.Drawing.Font($closingLabel.Font.FontFamily, 11)
            $closingLabel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 28)
            $closingLabel.Text = [string]$config.closingText

            $continueButton = New-Object System.Windows.Forms.Button
            $continueButton.AutoSize = $true
            $continueButton.Anchor = [System.Windows.Forms.AnchorStyles]::Right
            $continueButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $continueButton.Margin = New-Object System.Windows.Forms.Padding(0)
            $continueButton.Padding = New-Object System.Windows.Forms.Padding(24, 7, 24, 7)
            $continueButton.Text = [string]$config.continueButtonText

            [void]$layout.Controls.Add($repositoryLabel, 0, 0)
            [void]$layout.Controls.Add($headingLabel, 0, 1)
            [void]$layout.Controls.Add($reminderLabel, 0, 2)
            [void]$layout.Controls.Add($closingLabel, 0, 3)
            [void]$layout.Controls.Add($continueButton, 0, 4)
            [void]$form.Controls.Add($layout)

            $form.AcceptButton = $continueButton
            $form.CancelButton = $continueButton

            try {
                [void]$form.ShowDialog()
            }
            finally {
                $form.Dispose()
            }
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
