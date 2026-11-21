<#
.SYNOPSIS
    Compiles one farm stage script with tfwrc and copies it into a game save folder as main.py.

.DESCRIPTION
    Finds farm/stages/Stage<Stage>*.cs, compiles it with
    `dotnet run --project src/tfwrc -c Release -- --lang cs --toplevel`,
    and copies the generated .py file to <save folder>/main.py.
    The file name is always main.py so the game only needs a save reload
    the first time; later stages are picked up by the game's file watcher.

.PARAMETER Stage
    Stage number (matches farm/stages/Stage<Stage><Name>.cs).

.PARAMETER Save
    Save name under the game's Saves folder. Defaults to Save0.

.PARAMETER SaveDir
    Explicit target folder. Overrides -Save when given.

.EXAMPLE
    pwsh farm/deploy.ps1 -Stage 1
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 2147483647)]
    [int]$Stage,

    [string]$Save = 'Save0',

    [string]$SaveDir
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$stagesDir = Join-Path $PSScriptRoot 'stages'

# Stage1 must not match Stage10, so require a non-digit right after the number.
$stageFiles = @(Get-ChildItem -Path $stagesDir -Filter '*.cs' -File |
    Where-Object { $_.BaseName -match "^Stage$Stage(?!\d)" })
if ($stageFiles.Count -eq 0) {
    throw "No stage file found for stage $Stage in $stagesDir."
}
if ($stageFiles.Count -gt 1) {
    throw "More than one stage file found for stage ${Stage}: $($stageFiles.Name -join ', ')"
}
$stageFile = $stageFiles[0]

if ([string]::IsNullOrWhiteSpace($SaveDir)) {
    # Windows location documented in the game's docs/external_editor.md.
    $savesRoot = Join-Path $env:USERPROFILE 'AppData\LocalLow\TheFarmerWasReplaced\TheFarmerWasReplaced\Saves'
    $SaveDir = Join-Path $savesRoot $Save
}
if (-not (Test-Path -LiteralPath $SaveDir -PathType Container)) {
    throw "Save folder not found: $SaveDir. Start the game once or check the save name."
}

$outDir = Join-Path ([System.IO.Path]::GetTempPath()) ("tfwr-farm-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $outDir | Out-Null
try {
    $compilerProject = Join-Path (Join-Path $repoRoot 'src') 'tfwrc'
    Write-Host "Compiling $($stageFile.Name) ..."
    & dotnet run --project $compilerProject -c Release -- --lang cs --toplevel --out $outDir $stageFile.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "tfwrc failed with exit code $LASTEXITCODE."
    }

    $generated = @(Get-ChildItem -Path $outDir -Filter '*.py' -File -Recurse)
    if ($generated.Count -ne 1) {
        throw "Expected exactly one generated .py file, found $($generated.Count)."
    }

    $target = Join-Path $SaveDir 'main.py'
    $isNewFile = -not (Test-Path -LiteralPath $target)
    Copy-Item -LiteralPath $generated[0].FullName -Destination $target -Force

    Write-Host "Deployed stage $Stage to $target"
    if ($isNewFile) {
        Write-Host 'main.py is a new file: reload the save in the game so it shows up.'
    }
    Write-Host '----- main.py -----'
    Get-Content -LiteralPath $target | ForEach-Object { Write-Host $_ }
}
finally {
    Remove-Item -LiteralPath $outDir -Recurse -Force -ErrorAction SilentlyContinue
}
