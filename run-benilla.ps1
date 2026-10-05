# Runs the release benilla client.
# Every parameter is optional. -Password is required when -User is passed.
# Usage: .\run-benilla.ps1 [-User <account> -Password <password>] [-Char <character>] [-DataFolder <path>] [extra benilla args...]
param(
    [string]$User,

    [Alias('Pass')]
    [string]$Password,

    [string]$Char,

    [string]$DataFolder,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$BenillaArgs
)

if ($PSBoundParameters.ContainsKey('User') -and -not $PSBoundParameters.ContainsKey('Password')) {
    Write-Error "-Password is required when -User is passed."
    exit 1
}

if ($PSBoundParameters.ContainsKey('User')) {
    $env:WOW_USER = $User
}

if ($PSBoundParameters.ContainsKey('Password')) {
    $env:WOW_PASS = $Password
}

if ($PSBoundParameters.ContainsKey('Char')) {
    $env:WOW_CHAR = $Char
}

if ($PSBoundParameters.ContainsKey('DataFolder')) {
    $env:WOW_DATA = $DataFolder
}

$exe = Join-Path $PSScriptRoot 'target\release\benilla.exe'
if (-not (Test-Path $exe)) {
    Write-Error "benilla.exe not found at $exe (build with: cargo build --release)"
    exit 1
}

& $exe @BenillaArgs
exit $LASTEXITCODE
