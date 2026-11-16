$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
try {
    if (-not (Test-Path -LiteralPath (Join-Path $root 'compose.yaml'))) { throw 'Extract these diagnostic files beside the existing compose.yaml, not inside windows and not into a new install.' }
    . (Join-Path $root 'windows/docker-preflight.ps1')
    . (Join-Path $root 'windows/path-preflight.ps1')
    Assert-LocalBundlePath -Path $root
    $preflight = Get-DockerPreflight
    Write-DockerPreflight -Result $preflight
    if ($preflight.Status -ne 'ready') { exit 1 }
    $dockerExe = $preflight.Executable
    $base = @('compose','--project-directory',$root,'--file',(Join-Path $root 'compose.yaml'))
    $existing = @(& $dockerExe @base ps --all --quiet)
    if ($LASTEXITCODE -ne 0) { throw 'Could not query the existing Compose project.' }
    $existing = @($existing | Where-Object { $_ -and $_.Trim() })
    if ($existing.Count -eq 0) { throw 'No existing containers found at this location. No setup or volume creation was attempted.' }
    foreach ($id in $existing) {
        $raw = & $dockerExe inspect --format '{{json .Config.Labels}}' $id
        if ($LASTEXITCODE -ne 0) { throw 'Container inspection failed; ownership was not verified.' }
        $labels = ConvertFrom-Json -InputObject ($raw -join "`n")
        $property = @($labels.PSObject.Properties | Where-Object { $_.Name -ceq 'io.personal-lobster.kit' })
        if ($property.Count -ne 1 -or $property[0].Value -cne 'v1') { throw 'Unrecognized container; no diagnosis was started.' }
    }
    Write-Host 'Diagnostic only: no repair, login, model call, service restart, or config contents.'
    & $dockerExe @base ps
    if ($LASTEXITCODE -ne 0) { throw 'Could not read service status.' }
    $diagnostic = [IO.File]::ReadAllText((Join-Path $root 'check-state.cjs'))
    $diagnostic += "`nmodule.exports.main().catch(e => { console.error(JSON.stringify({diagnosticError:module.exports.errorTree(e)})); process.exitCode=1; });`n"
    $running = @(& $dockerExe @base ps --status running --quiet gateway)
    if ($LASTEXITCODE -ne 0) { throw 'Could not determine whether the existing Gateway is running.' }
    if (@($running | Where-Object { $_ -and $_.Trim() }).Count -gt 0) {
        Write-Host 'Using the running Gateway PID namespace.'
        $diagnostic | & $dockerExe @base exec -T gateway node
    } else {
        Write-Host 'Gateway is stopped. A fresh owner heartbeat may require waiting before offline diagnosis.'
        $diagnostic | & $dockerExe @base run --rm --no-deps -T --entrypoint node gateway
    }
    if ($LASTEXITCODE -ne 0) { throw 'Diagnostic could not complete. Existing service and login were not reset.' }
} catch { Write-Host ('STOP: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }
