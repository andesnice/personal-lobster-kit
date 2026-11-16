param([string]$Action = 'setup')
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path $PSScriptRoot 'docker-preflight.ps1')
. (Join-Path $PSScriptRoot 'path-preflight.ps1')
function Compose {
    & $script:DockerExe compose --project-directory $root --file (Join-Path $root 'compose.yaml') @args
    if ($LASTEXITCODE -ne 0) { throw 'Docker Compose command failed. No completion is assumed; inspect the error above.' }
}
try {
    if ($Action -notin @('setup','start','stop','login','dashboard','channels','doctor','models','logs','check','token')) { throw 'Unknown Docker action.' }
    Assert-LocalBundlePath -Path $root
    $preflight = Get-DockerPreflight
    Write-DockerPreflight -Result $preflight
    if ($preflight.Status -ne 'ready') { exit 1 }
    $script:DockerExe = $preflight.Executable
    if ($Action -eq 'check') { exit 0 }
    $existing = @(Compose ps --all --quiet)
    foreach ($container in $existing) {
        if (-not $container) { continue }
        $labelJson = & $script:DockerExe inspect --format '{{json .Config.Labels}}' "$container"
        if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the Compose container; ownership was not verified. No containers were changed.' }
        try {
            $jsonText = ($labelJson -join "`n").Trim()
            if ($jsonText -notmatch '^(?:\{|null\s*$)') { throw 'Expected a JSON object or null.' }
            $labels = ConvertFrom-Json -InputObject $jsonText -ErrorAction Stop
            if ($null -ne $labels -and $labels -isnot [PSCustomObject]) { throw 'Expected a JSON object or null.' }
        } catch { throw 'Docker returned invalid label JSON; ownership was not verified. No containers were changed.' }
        $label = $null
        if ($null -ne $labels) {
            $property = @($labels.PSObject.Properties | Where-Object { $_.Name -ceq 'io.personal-lobster.kit' })
            if ($property.Count -eq 1) { $label = $property[0].Value }
        }
        if ($label -cne 'v1') { throw 'This Compose project contains a different installation or has no kit ownership label. Choose another COMPOSE_PROJECT_NAME; no containers were replaced.' }
    }
    function Test-GatewayRunning {
        $ids = @(Compose ps --status running --quiet gateway)
        return @($ids | Where-Object { $_ -and $_.Trim() }).Count -gt 0
    }
    function GatewayCli {
        param([string[]]$Arguments, [switch]$Interactive)
        if (Test-GatewayRunning) {
            $prefix = @('exec')
            if (-not $Interactive) { $prefix += '-T' }
            $prefix += @('gateway','node','/app/openclaw.mjs','--profile','personal-lobster')
            Compose @prefix @Arguments
        } else { Compose run --rm --no-deps gateway @Arguments }
    }
    $gatewayWasRunning = Test-GatewayRunning
    if ($Action -eq 'setup' -and $gatewayWasRunning) {
        Write-Host 'Existing Gateway is running. Keeping config/login/data; opening it without reinstalling.'
        $Action = 'start'
    }
    if ($Action -eq 'setup') {
        Compose pull gateway init
        Compose run --rm --no-deps init
        Compose run --rm --no-deps gateway config validate
        Write-Host 'Sign in using YOUR OWN ChatGPT/Codex account. Do not share the device code.'
        Compose run --rm --no-deps gateway models auth login --provider openai --device-code
    }
    if ($Action -in @('setup','start')) {
        if (-not $gatewayWasRunning) { Compose up -d gateway }
        $healthy = $false
        for ($i=0; $i -lt 20; $i++) {
            & $script:DockerExe compose --project-directory $root --file (Join-Path $root 'compose.yaml') exec -T gateway node /app/openclaw.mjs --profile personal-lobster health --json *> $null
            if ($LASTEXITCODE -eq 0) { $healthy = $true; break }
            Start-Sleep -Seconds 2
        }
        if (-not $healthy) { throw 'Gateway health not confirmed. Use logs; do not reset/delete the volume.' }
        Write-Host 'Gateway health passed. First real AI reply still requires your own chat test.'
        Compose exec -T gateway node /app/openclaw.mjs --profile personal-lobster dashboard --no-open
        Write-Host 'If the local page asks for Gateway secret, use windows/DOCKER-TOKEN.bat. This is separate from the Codex device code; do not reinstall.'
    } elseif ($Action -eq 'token') {
        if (-not $gatewayWasRunning) { throw 'Start the owned Gateway first, then use the token entrypoint in your own interactive terminal.' }
        Write-Host 'Gateway token is for YOUR local web page only. Do not paste it into chat, screenshots or diagnostic logs.'
        Compose exec gateway node /app/openclaw.mjs --profile personal-lobster gateway auth-token --show
    } elseif ($Action -eq 'stop') { Compose stop gateway
    } elseif ($Action -eq 'logs') { Compose logs --tail 80 gateway
    } elseif ($Action -eq 'login') { GatewayCli -Arguments @('models','auth','login','--provider','openai','--device-code') -Interactive
    } elseif ($Action -eq 'channels') { GatewayCli -Arguments @('configure','--section','channels') -Interactive
    } elseif ($Action -eq 'doctor') { GatewayCli -Arguments @('doctor') -Interactive
    } elseif ($Action -eq 'models') { GatewayCli -Arguments @('models','list','--all','--provider','openai')
    } elseif ($Action -eq 'dashboard') { Compose exec -T gateway node /app/openclaw.mjs --profile personal-lobster dashboard --no-open }
} catch { Write-Host ('STOP: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }
