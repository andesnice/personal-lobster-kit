param([string]$Action = 'setup')
$ErrorActionPreference = 'Stop'
try {
    if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing official OpenClaw (no onboarding, no copied credentials)...'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $installer = Join-Path ([IO.Path]::GetTempPath()) ('openclaw-installer-' + [Guid]::NewGuid().ToString('N') + '.ps1')
        try {
            Invoke-WebRequest -UseBasicParsing -Uri 'https://openclaw.ai/install.ps1' -OutFile $installer
            & $installer -NoOnboard
            if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw 'Official installation failed.' }
        } finally { Remove-Item -LiteralPath $installer -ErrorAction SilentlyContinue }
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    }
    if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) { throw 'OpenClaw is not on PATH. Reopen this installer after reviewing the official installer output.' }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js not found. Install a version supported by OpenClaw, then rerun.' }
    & node (Join-Path $PSScriptRoot '..\shared\deploy.mjs') $Action
    if ($LASTEXITCODE -ne 0) { throw 'Deployment did not finish. Review the error above; existing data was not overwritten.' }
} catch {
    Write-Host ('STOP: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
