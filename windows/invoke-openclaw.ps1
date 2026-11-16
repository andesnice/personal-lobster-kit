param([Parameter(Mandatory=$true)][string]$ArgumentsFile)
$ErrorActionPreference = 'Stop'
$cliArgs = @(Get-Content -LiteralPath $ArgumentsFile -Raw -Encoding UTF8 | ConvertFrom-Json)
$command = Get-Command openclaw.cmd -ErrorAction SilentlyContinue
if (-not $command) { $command = Get-Command openclaw -ErrorAction Stop }
& $command.Source @cliArgs
exit $LASTEXITCODE
