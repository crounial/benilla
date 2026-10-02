# Runs the release benilla client with a login identity from the caller.
# Usage: .\run-benilla.ps1 -User <account> -Pass <password> -Char <character> [extra benilla args...]
param(
    [Parameter(Mandatory = $true)]
    [string]$User,

    [Parameter(Mandatory = $true)]
    [string]$Pass,

    [Parameter(Mandatory = $true)]
    [string]$Char,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$BenillaArgs
)

$env:WOW_USER = $User
$env:WOW_PASS = $Pass
$env:WOW_CHAR = $Char

$exe = Join-Path $PSScriptRoot 'target\release\benilla.exe'
if (-not (Test-Path $exe)) {
    Write-Error "benilla.exe not found at $exe (build with: cargo build --release)"
    exit 1
}

& $exe @BenillaArgs
exit $LASTEXITCODE
